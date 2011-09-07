class Ship extends THREE.Object3D
  constructor: ->
    super()
    @velocity = 0
    @useQuaternion = true
    @pitchVelocity = 0
    @rollVelocity = 0

    THREE.Mesh.loader.load( model: 'ship.js', callback: (geometry) => 
      material = new THREE.MeshPhongMaterial( { ambient: 0xff9900, specular: 0xff9900, shininess: 100 } )
      mesh = new THREE.Mesh( geometry, material )
      mesh.scale = new THREE.Vector3(0.2, 0.2, 0.2)
      @addChild(mesh)
    )

  direction: ->
    c_orient_axis = new THREE.Vector3();
    @quaternion.multiplyVector3(new THREE.Vector3(0,0,1), c_orient_axis)
    c_orient_axis

  addPitch: (direction) ->
    @pitchVelocity += 0.001 * direction
    if @pitchVelocity > 0.05
      @pitchVelocity = 0.05
    else if @pitchVelocity < -0.05
      @pitchVelocity = -0.05

  addRoll: (direction) ->
    @rollVelocity += 0.001 * direction
    if @rollVelocity > 0.05
      @rollVelocity = 0.05
    else if @rollVelocity < -0.05
      @rollVelocity = -0.05

  tick: (timestep) ->
    pitch = new THREE.Quaternion()
    pitch.setFromAxisAngle(new THREE.Vector3(1,0,0), @pitchVelocity)
    roll = new THREE.Quaternion()
    roll.setFromAxisAngle(new THREE.Vector3(0,0,1), @rollVelocity)
    @quaternion.multiplySelf(pitch).multiplySelf(roll)
    @pitchVelocity *= 0.98
    @rollVelocity *= 0.98

    @position.subSelf(@direction().multiplyScalar(0.05))
