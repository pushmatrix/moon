class Player extends THREE.Object3D
  constructor: (position) ->
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

    # Did you know you can do texture animation with UV offsets?
    @texture = THREE.ImageUtils.loadTexture "/public/robot.png"
    @sprite= new THREE.Sprite( { map: @texture, useScreenCoordinates: false, color: 0xffffff } );
    this.sprite.scale.y = 0.02
    this.sprite.scale.x = 0.015
    @add(@sprite)

    @voicePitch = Math.random()*100

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
