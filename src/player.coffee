class Player extends THREE.Object3D
  constructor: (@position) ->
    super()

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

