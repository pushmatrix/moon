class Milk.Controllable extends Milk.Component
	stage: ->
		Milk.KeyHandler.listen()

		game.client.observe 'willSendPlayerUpdate', (data) =>
			@updateNetwork data

	update: ->
		if Milk.KeyHandler.isDown 'up'
			@setAnimation?('run') if not @jumping
			@forward?(1)

		else if Milk.KeyHandler.isDown 'down'
			@setAnimation?('run') if not @jumping
			@forward?(-1)

		else if @currentAnimation is 'run'
			@setAnimation?('stand')

		if Milk.KeyHandler.isDown 'left'
			@turn?(1)

		if Milk.KeyHandler.isDown 'right'
			@turn?(-1)

		if Milk.KeyHandler.isDown 'space'
			if not @preventJump
				@setAnimation?('jump', 1)
				@jump()
