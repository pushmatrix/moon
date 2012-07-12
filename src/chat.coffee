class window.Chat
	constructor: ->
		@input = document.getElementById('chat')
		@input.addEventListener 'keydown', @keyDown, false

	showWindow: ->
		@input.value = ''
		@input.style.display = 'block'
		@input.focus()

	hideWindow: ->
		@input.blur()
		@input.style.display = 'none'

	sendMessage: ->
		game.player.displayMessage @input.value
		client.sendMessage @input.value

	keyDown: (e) =>
		e.stopPropagation()
		if e.keyCode is Key.KEYS.enter
			@sendMessage()
			@hideWindow()
		else if e.keyCode is Key.KEYS.escape
			@hideWindow()
