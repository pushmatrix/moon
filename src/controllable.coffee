class Milk.Controllable extends Milk.Component
	exportObject: ->
		@velocity = 0
		@yVelocity = 0
		@speed = 0.05
		@maxSpeed = 0.2

		@angularVelocity = 0
		@turnSpeed = 0.01
		@maxTurnSpeed = 0.02

		@object3D.useQuaternion = true

		Milk.KeyHandler.listen()

	update: ->
		if Milk.KeyHandler.isDown 'up' then @forward 1
		if Milk.KeyHandler.isDown 'down' then @forward -1
		if Milk.KeyHandler.isDown 'left' then @turn 1
		if Milk.KeyHandler.isDown 'right' then @turn -1

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
