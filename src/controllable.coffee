class Milk.Movable extends Milk.Component
	constructor: ->
		@velocity = 0
		@yVelocity = 0
		@speed = 0.05
		@maxSpeed = 0.2

		@angularVelocity = 0
		@turnSpeed = 0.01
		@maxTurnSpeed = 0.02

	exportObject: (object) ->
		object.useQuaternion = true

	forward: (direction) ->
		@velocity += @speed * direction
		if @velocity > @maxSpeed
			@velocity = @maxSpeed
		else if @velocity < -@maxSpeed
			@velocity = -@maxSpeed

	turn: (direction) ->
		@angularVelocity += @turnSpeed * direction
		if @angularVelocity > @maxTurnSpeed
			@angularVelocity = @maxTurnSpeed
		else if @angularVelocity < -@maxTurnSpeed
			@angularVelocity = - @maxTurnSpeed

	update: ->
		rotation = new THREE.Quaternion()
		rotation.setFromAxisAngle(new THREE.Vector3(0,1,0), @angularVelocity)
		@object3D.quaternion.multiplySelf(rotation)

		@angularVelocity *= 0.9
		@velocity *= 0.8
		@object3D.position.subSelf(@direction().multiplyScalar(@velocity))
		@object3D.position.y += @yVelocity
		@yVelocity -= 0.0005

		mapHeightAtPlayer = game.level.heightAtPosition @object3D.position
		magicNumber = 0.8#@player.boundingBox.max.y
		if mapHeightAtPlayer > @object3D.position.y - magicNumber
			@object3D.position.y = mapHeightAtPlayer + magicNumber
			@jumping = false

	direction: ->
		orient_axis = new THREE.Vector3
		@object3D.quaternion.multiplyVector3 new THREE.Vector3(0,0,1), orient_axis
		orient_axis

class Milk.Controllable extends Milk.Component
	constructor: ->
		@followDistance = 8

	exportObject: ->
		Milk.KeyHandler.listen()

	update: ->
		if Milk.KeyHandler.isDown 'up' then @forward? 1
		if Milk.KeyHandler.isDown 'down' then @forward? -1
		if Milk.KeyHandler.isDown 'left' then @turn? 1
		if Milk.KeyHandler.isDown 'right' then @turn? -1

class Milk.Jumpable extends Milk.Component
	exportObject: ->
		Milk.KeyHandler.listen()

	update: ->
		if Milk.KeyHandler.isDown 'space' then @jump()

	jump: ->
		if not @jumping
			@yVelocity = @speed
			@jumping = true
