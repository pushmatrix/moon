class Milk.Actor extends Milk
	direction: ->
		orient_axis = new THREE.Vector3
		@object3D.quaternion.multiplyVector3 new THREE.Vector3(0,0,1), orient_axis

		orient_axis

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

class Milk.Spaceman extends Milk.Actor
	constructor: ->
		super
		@sprite = new Milk.Sprite "public/robot.png", =>
			@exportObject @sprite.object3D
			@object3D.useQuaternion = true

	followDistance: 8

	stage: ->
		super
		@scene.add @sprite.object3D

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

	followDistance: 8

	constructor: (id, position, startingItems = []) ->
		super()
		@playerId = id
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


		@boundingBox = {max: new THREE.Vector3(1, 0.8, 1)}

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

	afterUpdate: ->
		@messageText?.positionOver this

	displayMessage: (message) ->
		@clearMessage() if @textMesh
		speak.play message, pitch: @voicePitch, @clearMessage

		@messageText = new TextObject message
		game.add @messageText

	clearMessage: =>
		game.remove @messageText
		@messageText = null
###
