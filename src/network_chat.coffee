class Milk.NetworkChat extends Milk
	constructor: ->
		super

		@input = document.getElementById('chat')
		@input.addEventListener 'keydown', @keyDown, false

		game.client.observe 'receiveMessage', @receiveMessage

	stage: ->
		Milk.KeyHandler.listen()

	update: ->
		if Milk.KeyHandler.isDown 'enter'
			@showWindow()

	showWindow: ->
		@input.value = ''
		@input.style.display = 'block'
		@input.focus()

	hideWindow: ->
		@input.blur()
		@input.style.display = 'none'

	sendMessage: ->
		message = @input.value
		return if not message

		data = {message: message}
		@fire 'willSendMessage', data

		now.sendMessage data if message

	receiveMessage: (data) =>
		return if not data.message
		@fire 'receiveMessage', data

		date = new Date()
		ul = document.getElementById 'chat-log'

		li = document.createElement 'li'
		li.innerText = li.textContent = "#{date.getHours()}:#{date.getMinutes()}:#{date.getSeconds()} - #{data.message}"
		li.style.cursor = 'pointer'
		li.addEventListener 'click', (=> @fire 'receiveMessage', data), false
		ul.appendChild li

		li = document.createElement 'li'
		li.innerHTML = '&nbsp;'
		ul.appendChild li
		li.scrollIntoView()

	keyDown: (e) =>
		e.stopPropagation()
		if e.keyCode is Milk.KeyHandler.KEY_MAP.enter
			@sendMessage()
			@hideWindow()
		else if e.keyCode is Milk.KeyHandler.KEY_MAP.escape
			@hideWindow()
