# still haven't decided if this baseclass is worth anything at all
class Milk.Actor extends Milk
	stage: ->
		super
		@scene.add @object3D

	unstage: ->
		@scene.remove @object3D

	update: (delta) ->
		super
		@object3D.update? delta

	updateNetwork: (data) ->
		@componentDispatch 'updateNetwork', [data]

	receiveNetworkUpdate: (data) ->
		@componentDispatch 'receiveNetworkUpdate', [data]

class Milk.Alien extends Milk.Actor
	constructor: ->
		super
		@notReady()

		options = {
			baseUrl: "public/ratamahatta/"
			body: "ratamahatta.js"
			skins: [ "ratamahatta.png", "ctf_b.png", "ctf_r.png", "dead.png", "gearwhore.png" ]
			weapons: [  [ "weapon.js", "weapon.png" ],
								 [ "w_bfg.js", "w_bfg.png" ],
								 [ "w_blaster.js", "w_blaster.png" ],
								 [ "w_chaingun.js", "w_chaingun.png" ],
								 [ "w_glauncher.js", "w_glauncher.png" ],
								 [ "w_hyperblaster.js", "w_hyperblaster.png" ],
								 [ "w_machinegun.js", "w_machinegun.png" ],
								 [ "w_railgun.js", "w_railgun.png" ],
								 [ "w_rlauncher.js", "w_rlauncher.png" ],
								 [ "w_shotgun.js", "w_shotgun.png" ],
								 [ "w_sshotgun.js", "w_sshotgun.png" ]
							 ]
		}

		@character = new THREE.MD2Character
		@character.scale = 0.08
		@character.onLoadComplete = =>
			@character.meshBody.rotation.y = 1.5

			box = @character.meshBody.geometry.boundingBox.max
			scale = @character.meshBody.scale
			bounds = new THREE.Vector3().multiply(box, scale)
			@exportObject @character.root, bounds

			@ready()
		@character.loadParts options

	maxSpeed: 1.3
	followDistance: 9
	groundCollisionMinimum: 2

	update: (delta) ->
		super
		@character.update delta

class Milk.Spaceman extends Milk.Actor
	constructor: ->
		super
		@notReady()
		@sprite = new Milk.Sprite "public/robot.png", =>
			@exportObject @sprite.object3D, @sprite.bounds
			@ready()

	followDistance: 8
	groundCollisionMinimum: 0.8

class Milk.Animation extends Milk.Component
	setAnimation: (name, fps=6) ->
		return if @currentAnimation is name
		@character?.animationFPS = fps
		@character?.setAnimation? name

		@currentAnimation = name
		@currentFPS = fps

	updateNetwork: (data) ->
		data.animation =
			name: @currentAnimation || 'stand'
			fps: @currentFPS

	receiveNetworkUpdate: (data) ->
		if data.animation
			@setAnimation data.animation.name, data.animation.fps

class Milk.Movable extends Milk.Component
	constructor: ->
		@velocity = 0
		@yVelocity = 0
		@speed = 0.05
		@maxSpeed = 0.2

		@angularVelocity = 0
		@turnSpeed = 0.01
		@maxTurnSpeed = 0.02

	exportObject: ->
		@object3D.useQuaternion = true

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

	jump: ->
		if not @jumping
			@yVelocity = @speed
			@jumping = true

	update: ->
		return if not @object3D
		rotation = new THREE.Quaternion()
		rotation.setFromAxisAngle(new THREE.Vector3(0,1,0), @angularVelocity)
		@object3D.quaternion.multiplySelf(rotation)

		@angularVelocity *= 0.9
		if @velocity < 0.001 and @velocity > 0.001 then @velocity = 0 else @velocity *= 0.8
		@object3D.position.subSelf(@direction().multiplyScalar(@velocity))
		@object3D.position.y += @yVelocity
		@yVelocity -= 0.0005

		mapHeightAtPlayer = game.level.heightAtPosition @object3D.position
		magicNumber = @groundCollisionMinimum
		if mapHeightAtPlayer > @object3D.position.y - magicNumber
			@object3D.position.y = mapHeightAtPlayer + magicNumber
			if @jumping
				@jumping = false
				@setAnimation?('stand')

	updateNetwork: (data) ->
		data.position = @object3D.position
		data.quaternion = @object3D.quaternion

	receiveNetworkUpdate: (data) ->
		if data.position
			@yVelocity = 0
			@object3D.position.x = data.position.x
			@object3D.position.y = data.position.y
			@object3D.position.z = data.position.z

		if data.quaternion
			@object3D.quaternion.x = data.quaternion.x
			@object3D.quaternion.y = data.quaternion.y
			@object3D.quaternion.z = data.quaternion.z
			@object3D.quaternion.w = data.quaternion.w

	direction: ->
		orient_axis = new THREE.Vector3
		@object3D.quaternion.multiplyVector3 new THREE.Vector3(0,0,1), orient_axis
		orient_axis

###
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

	constructor: (id, position, startingItems = []) ->
		@items = {}


		@boundingBox = {max: new THREE.Vector3(1, 0.8, 1)}

		for item in startingItems
			@equipItem(item)

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

###
