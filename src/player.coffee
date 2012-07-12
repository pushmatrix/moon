class Player extends THREE.Object3D

  ITEM_OPTIONS =
    dino: 'mask'
    helmet: 'mask'
    hat: 'hat'
    milk: 'hand'
    cookies: 'hand'

  ITEM_OFFSETS =
    mask: 
      x: 0
      y: 0.6
    hand: 
      x: 0.45
      y: 0
    hat:
      x: 0
      y: 0.9


  constructor: (position, startingItems = []) ->
    super()
    @position = position

    @velocity = 0
    @yVelocity = 0
    @speed = 0.05
    @maxSpeed = 0.2

    @angularVelocity = 0
    @turnSpeed = 0.01
    @maxTurnSpeed = 0.02
    @useQuaternion = true

    @jumping = false
    @scaleFactor = 0.0001

    @items = {}

    # Did you know you can do texture animation with UV offsets?
    @sprite = new Sprite("robot.png")
    @add(@sprite)

    @voicePitch = Math.random()*100

    for item in startingItems
      @equipItem(item)

  direction: ->
    c_orient_axis = new THREE.Vector3();
    @quaternion.multiplyVector3(new THREE.Vector3(0,0,1), c_orient_axis)
    c_orient_axis

  forward: (direction) ->
    @velocity += @speed * direction
    if @velocity > @maxSpeed
      @velocity = @maxSpeed
    else if @velocity < -@maxSpeed
      @velocity = -@maxSpeed

  jump: (direction) ->
    if !@jumping
      @yVelocity = @speed
      @jumping = true

  turn: (direction) ->
    @angularVelocity += @turnSpeed * direction
    if @angularVelocity > @maxTurnSpeed
      @angularVelocity = @maxTurnSpeed
    else if @angularVelocity < -@maxTurnSpeed
      @angularVelocity = - @maxTurnSpeed

  equipItem: (item) ->
    unless @items[item]
      itemSprite = new Sprite("#{item}.png")
      slot = ITEM_OPTIONS[item] || "hand"
      offset = ITEM_OFFSETS[slot]
      itemSprite.position.set(offset.x, offset.y, 0.001)
      @add(itemSprite)
      @items[item] = itemSprite
 
  unequipItem: (item) ->
    if @items[item]
      @remove @items[item]
      @items[item] = null
      delete @items[item]

  update: (timestep) ->
    rotation = new THREE.Quaternion()
    rotation.setFromAxisAngle(new THREE.Vector3(0,1,0), @angularVelocity)
    @quaternion.multiplySelf(rotation)
    @angularVelocity *= 0.9
    @velocity *= 0.8
    @position.subSelf(@direction().multiplyScalar(@velocity))
    @position.y += @yVelocity
    @yVelocity -= 0.0005

  updateChildren: ->
    if mesh = @textMesh
      mesh.position.x = @position.x
      mesh.position.y = @position.y + 1.1
      mesh.position.z = @position.z

      mesh.lookAt game.camera.position
      mesh.translateX -mesh.width

  TEXT_OPTIONS = {
    size: 32
    height: 6
    curveSegments: 4
    font: "helvetiker"
    weight: "normal"
    style: "normal"
    bevelEnabled: true
    bevelThickness: 0.25
    bevelSize: 0.25
    bend: false
    material: 0
    extrudeMaterial: 1
  }

  displayMessage: (message) ->
    @clearMessage() if @textMesh
    speak.play message, pitch: @voicePitch, @clearMessage

    faceMaterial = new THREE.MeshFaceMaterial
    frontMaterial = new THREE.MeshBasicMaterial color: 0xffffff, shading: THREE.FlatShading
    sideMaterial = new THREE.MeshBasicMaterial color: 0xbbbbbb, shading: THREE.SmoothShading

    geo = new THREE.TextGeometry message, TEXT_OPTIONS
    geo.materials = [frontMaterial, sideMaterial]
    geo.computeBoundingBox()
    geo.computeVertexNormals()

    @textMesh = mesh = new THREE.Mesh geo, faceMaterial
    mesh.scale.x = mesh.scale.y = mesh.scale.z = 0.01
    mesh.width = geo.boundingBox.max.x * mesh.scale.x / 2

    game.add mesh


  clearMessage: =>
    game.remove @textMesh
