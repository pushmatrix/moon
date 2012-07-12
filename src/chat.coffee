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
		message = @input.value
		client.sendMessage message if message

	receiveMessage: (data) ->
		callback = -> game.players[data.id].displayMessage data.message
		callback()

		date = new Date()
		li = document.createElement 'li'
		li.innerText = li.textContent = "#{date.getHours()}:#{date.getMinutes()}:#{date.getSeconds()} - #{data.message}"
		li.addEventListener 'click', callback, false

		document.getElementById('chat-log').appendChild(li)
		li.scrollIntoView()

	keyDown: (e) =>
		e.stopPropagation()
		if e.keyCode is Key.KEYS.enter
			@sendMessage()
			@hideWindow()
		else if e.keyCode is Key.KEYS.escape
			@hideWindow()
