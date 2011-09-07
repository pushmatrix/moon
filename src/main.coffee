class Key
  @UP = 38
  @DOWN = 40
  @LEFT = 37
  @RIGHT = 39
  
  window.addEventListener('keyup', ((event) => @onKeyup(event)), false)
  window.addEventListener('keydown', ((event) => @onKeydown(event)), false)
  
  @_pressed: {}
  
  @isDown: (keyCode) ->
    @_pressed[keyCode]

  @onKeydown: (event) ->
    @_pressed[event.keyCode] = true

  @onKeyup: (event) ->
    delete @_pressed[event.keyCode]

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
      @camera.updateProjectionMatrix()

      @renderer.setSize w, h

  render: (time) =>
    requestAnimationFrame @render, @renderer.domElement
    timestep = (time - @lastFrameTime) * 0.001
    
    do @stats.update

    
    if Key.isDown(Key.UP) then @ship.addPitch(-1)
    if Key.isDown(Key.DOWN) then @ship.addPitch(1)
    if Key.isDown(Key.LEFT) then @ship.addRoll(1)
    if Key.isDown(Key.RIGHT) then @ship.addRoll(-1)

    @ship.tick(timestep)
    
    target = @ship.position.clone().subSelf(@ship.direction().multiplyScalar(-3))
    @camera.quaternion = THREE.Quaternion.slerp(@camera.quaternion, @ship.quaternion, new THREE.Quaternion, 0.15).normalize() 
    @camera.position = @camera.position.addSelf(target.subSelf(@camera.position).multiplyScalar(0.1))

    @renderer.render @scene, @camera
    @lastFrameTime = time

  constructor: ->
    #@camera = new THREE.TrackballCamera fov: 45, movementSpeed: 0.8, rollSpeed: 1, aspect: window.innerWidth / window.innerHeight, near: 1, far: 10000
    @camera = new THREE.Camera(45, window.innerWidth / window.innerHeight, 1, 10000)
    @camera.position.z = 2
    @camera.useTarget = false
    @camera.useQuaternion = true

    @scene = new THREE.Scene
    
    @planet = new THREE.Mesh(new THREE.SphereGeometry(0.5,20,20), new THREE.MeshPhongMaterial({ map: THREE.ImageUtils.loadTexture("images/earth.jpg"), color: 0xFF99FF}))
    @planet.position.z = -1.9
    @addObject(@planet)
    
    urlPrefix	= "images/"
    urls = [ urlPrefix + "stars.png", urlPrefix + "stars.png",
    urlPrefix + "stars.png", urlPrefix + "stars.png",
    urlPrefix + "stars.png", urlPrefix + "stars.png" ]
    skyTexture = THREE.ImageUtils.loadTextureCube(urls)
    skyShader = THREE.ShaderUtils.lib["cube"];
    skyShader.uniforms["tCube"].texture = skyTexture
    
    material = new THREE.MeshShaderMaterial({
      uniforms: skyShader.uniforms,
      vertexShader: skyShader.vertexShader,
      fragmentShader: skyShader.fragmentShader,
    })
    
    @space = new THREE.Mesh(new THREE.CubeGeometry(10000, 10000, 10000, 1, 1, 1, null, true), material)
    @space = new THREE.Mesh(new THREE.CubeGeometry(10000, 10000, 10000, 1, 1, 1, null, true), material)
    @addObject(@space)
    
    @ship = new Ship()
    @addObject(@ship)
    
   # geometry = new THREE.Geometry()
   # for i in [0..4000]
   #   vector = new THREE.Vector3( Math.random() * 1000 - 500, Math.random() * 1000 - 500, Math.random() * 1000 - 500 )
   #   geometry.vertices.push( new THREE.Vertex( vector ) )
   # material = new THREE.ParticleBasicMaterial()
    #@particles = new THREE.ParticleSystem( geometry, material )
    #@scene.addObject( @particles )

    @light = new THREE.PointLight 0xffffff
    @light.position = @camera.position
    @scene.addLight @light

    @createRenderer()
    @lastFrameTime = Date.now()
    requestAnimationFrame @render, @renderer.domElement

  addObject: (object) ->
    @scene.addObject object

# Uncomment for .obj loading capabilities
THREE.Mesh.loader = new THREE.JSONLoader()

window.onload = ->
  game = new Scene()
  window.game = game
  window.key = Key
