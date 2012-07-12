class Milk.KeyHandler extends Milk
	KEY_MAP = {
		'up': 38
		'down': 40
		'left': 37
		'right': 39
		'space': 32
		'enter': 13
		'escape': 27
		'e': 69
	}

	@listen: ->
		console.log 'listening'
		return if @downListener
		@pressed = {}
		@downListener = window.addEventListener 'keydown', (e) => @pressed[e.keyCode] = true
		@upListener = window.addEventListener 'keyup', (e) => @pressed[e.keyCode] = false

	@isDown: (keyName) ->
		@pressed[KEY_MAP[keyName]]
