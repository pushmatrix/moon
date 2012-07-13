class Milk.Controllable extends Milk.Component
	constructor: ->
		@followDistance = 8

	exportObject: ->
		Milk.KeyHandler.listen()

	update: ->
		if Milk.KeyHandler.isDown 'up'
			@forward?(1)
			@queueUpdate?()

		if Milk.KeyHandler.isDown 'down'
			@forward?(-1)
			@queueUpdate?()

		if Milk.KeyHandler.isDown 'left'
			@turn?(1)
			@queueUpdate?()

		if Milk.KeyHandler.isDown 'right'
			@turn?(-1)
			@queueUpdate?()

class Milk.Jumpable extends Milk.Component
	exportObject: ->
		Milk.KeyHandler.listen()

	update: ->
		if Milk.KeyHandler.isDown 'space'
			@jump()
			@queueUpdate?()
		else if @jumping
			@queueUpdate?()

	jump: ->
		if not @jumping
			@yVelocity = @speed
			@jumping = true
