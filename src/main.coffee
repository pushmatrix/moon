clock = new THREE.Clock()
publicUrl = "/public/"


class window.Key
  @KEYS: {
    'up': 38
    'down': 40
    'left': 37
    'right': 39
    'space': 32
    'enter': 13
    'escape': 27
  }

  constructor: (node, @map) ->
    @pressed = []
    node.addEventListener 'keydown', @onKeyDown, false
    node.addEventListener 'keyup', @onKeyUp, false

  update: (callContext) ->
    for name, func of @map
      keyCode = Key.KEYS[name]
      func.call(callContext) if @isDown keyCode

  isDown: (keyCode) ->
    @pressed[keyCode]

  onKeyDown: (event) =>
    console.log event.keyCode if window.debugKeyCodes
    @pressed[event.keyCode] = true

  onKeyUp: (event) =>
    @pressed[event.keyCode] = false unless @handlingKeys

class Scene
  createRenderer: ->
    @container = document.createElement 'div'
    document.body.appendChild @container

    @renderer = new THREE.WebGLRenderer antialias: true
    @renderer.setSize window.innerWidth, window.innerHeight
    @container.appendChild @renderer.domElement

    if Stats?
      @stats = new Stats()
      @stats.domElement.style.position = 'absolute'
      @stats.domElement.style.top = '0px'
      @container.appendChild @stats.domElement

    window.addEventListener 'resize', =>
      w = window.innerWidth
      h = window.innerHeight

      @camera.aspect = w / h

      @renderer.setSize w, h

  constructor: ->
    @handler = new Key window, {
      'up': -> @player.forward 1
      'down': -> @player.forward -1
      'left': -> @player.turn 1
      'right': -> @player.turn -1
      'space': -> @player.jump 1
      'enter': -> chat.showWindow()
    }

    @scene = new THREE.Scene

    ## CAMERA
    fov = 50
    aspect = window.innerWidth / window.innerHeight
    near = 1
    far = 100000
    @camera = new THREE.PerspectiveCamera fov, aspect, near, far
    @scene.add(@camera)

    ## PLAYERS
    @players = {}

    ## MOON
    @moon = new Moon(128, 128, 127, 127)
    @add(@moon)

    ## SKYBOX
    urls =
      [
        "#{publicUrl}/stars.png" #pos-x
        "#{publicUrl}/stars.png" #neg-x
        "#{publicUrl}/stars.png" #pos-y
        "#{publicUrl}/stars.png" #neg-y
        "#{publicUrl}/stars.png" #pos-z
        "#{publicUrl}/stars.png" #neg-z
      ]
    skyTexture = THREE.ImageUtils.loadTextureCube(urls)
    skyTexture.wrapS = THREE.RepeatWrapping;
    skyTexture.wrapT = THREE.RepeatWrapping;
    skyTexture.repeat.x = 100;
    skyTexture.repeat.y = 100;

    skyShader = THREE.ShaderUtils.lib["cube"]
    skyShader.uniforms["tCube"].texture = skyTexture

    skyMaterial = new THREE.ShaderMaterial
      uniforms: skyShader.uniforms
      vertexShader: skyShader.vertexShader
      fragmentShader: skyShader.fragmentShader
      depthWrite: false

    @skybox = new THREE.Mesh(new THREE.CubeGeometry(10000, 10000, 10000, 1, 1, 1, null, true), skyMaterial)
    @skybox.flipSided = true
    @add(@skybox)

    ## MILK
    geometry = new THREE.PlaneGeometry(128, 128, 1, 1)
    material = new THREE.MeshLambertMaterial( map: THREE.ImageUtils.loadTexture("/public/milk.jpg") )
    @milk = new THREE.Mesh(geometry, material)
    @milk.doubleSided = true
    @milk.position.y = 5
    @add(@milk)

    ## EARTH
    @earth = new THREE.Mesh(new THREE.SphereGeometry(50,20,20), new THREE.MeshLambertMaterial(map: THREE.ImageUtils.loadTexture("/public/earth.jpg"), color: 0x0))
    @earth.position.z= 500
    @earth.position.y= 79
    @earth.rotation.y = 2.54
    @add(@earth)


    # LIGHTING
    @light = new THREE.PointLight 0xffffff
    @ambient = new THREE.AmbientLight( 0x999999)
    @light.position = @camera.position
    @add(@light)
    @add(@ambient)

    # FOG
    @scene.fog = new THREE.Fog( 0xffffff, 1, 10000)

    @createRenderer()

  add: (object) ->
    @scene.add object

  addPlayer: (id, position = new THREE.Vector3(7,15,7), currentPlayer = false) ->
    p = new Player(position)
    @players[id] = p
    @add(p)
    if currentPlayer
      @player = p
      requestAnimationFrame @render, @renderer.domElement

# Uncomment for .obj loading capabilities
# THREE.Mesh.loader = new THREE.JSONLoader()

  render: (time) =>
    return unless @player

    delta = clock.getDelta()
    requestAnimationFrame @render, @renderer.domElement
    timestep = (time - @lastFrameTime) * 0.001

    @stats.update()
    @handler.update(this)

    @player.update(delta)

    mapHeightAtPlayer = @moon.getHeight(@player.position.x, @player.position.z)
    if mapHeightAtPlayer > @player.position.y - 0.8
      @player.position.y = mapHeightAtPlayer + 0.8
      @player.jumping = false

    target = @player.position.clone().subSelf(@player.direction().multiplyScalar(-8))
    @camera.position = @camera.position.addSelf(target.subSelf(@camera.position).multiplyScalar(0.1))

    mapHeightAtCamera = @moon.getHeight(@camera.position.x, @camera.position.z)
    if mapHeightAtCamera > (@player.position.y - 2)
      @camera.position.y = mapHeightAtCamera + 2
      @player.jumping = false

    @camera.lookAt(@player.position)


    if @player.position.y < (@milk.position.y - 3)
      @scene.fog.far = 20
    else
      @scene.fog.far = 10000

    @earth.rotation.y += 0.01
    @earth.rotation.z += 0.005
    @earth.rotation.x += 0.005
    @renderer.render @scene, @camera


$(document).ready ->
  game = new Scene
  client = new Client game

  window.chat = new Chat
  window.game = game
