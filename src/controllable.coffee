class Milk.Controllable extends Milk.Component
	stage: ->
		Milk.KeyHandler.listen()

	update: ->
		if Milk.KeyHandler.isDown 'up'
			@setAnimation?('run') if not @jumping
			@forward?(1)
			@queueUpdate?()

		else if Milk.KeyHandler.isDown 'down'
			@setAnimation?('run') if not @jumping
			@forward?(-1)
			@queueUpdate?()

		else if @currentAnimation is 'run'
			@setAnimation?('stand')

		if Milk.KeyHandler.isDown 'left'
			@turn?(1)
			@queueUpdate?()

		if Milk.KeyHandler.isDown 'right'
			@turn?(-1)
			@queueUpdate?()

		if Milk.KeyHandler.isDown 'space'
			if not @preventJump
				@setAnimation?('jump', 1)
				@jump()
				@queueUpdate?()
		else if @jumping
			@queueUpdate?()
