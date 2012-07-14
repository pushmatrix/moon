class Milk.NetworkClient extends Milk
	@UPDATE_INTERVAL = 30

	constructor: ->
		super
		@players = {}

		now.welcome = (data) =>
			console.log 'MY ID IS', @id()
			if data.players
				for id, player of data.players
					addPlayer player

		now.addPlayer = addPlayer = (data) =>
			return if data.id is @id()
			@players[data.id] = data
			@fire 'addPlayer', data

		now.removePlayer = (data) =>
			throw "BAD THINGS" if data.id is @id()
			@players[data.id] = null
			delete @players[data.id]

			@fire 'removePlayer', data

		now.receivePlayerUpdate = (data) =>
			return if data.id is @id()

			player = @players[data.id]
			return if not player

			for key, value of data
				player[key] = value

			@fire 'receivePlayerUpdate', player

		now.receiveMessage = (data) =>
			data.self = true if data.id is @id()
			@fire 'receiveMessage', data

		now.receiveChangePlayerActor = (data) =>
			return if data.id is @id()
			@fire 'receiveChangePlayerActor', data

	id: -> now.core.clientId

	stage: ->
		super
		@playerUpdateInterval = setInterval =>
			return if not now.sendPlayerUpdate
			data = {}
			@fire 'willSendPlayerUpdate', data

			now.sendPlayerUpdate data if not data.cancel
		, Milk.NetworkClient.UPDATE_INTERVAL

	unstage: ->
		return if not @playerUpdateInterval
		clearInterval @playerUpdateInterval
		@playerUpdateInterval = null

###
class Client
	now = window.now
	constructor: (@game) ->

		now.updateInventory = (data) =>
			player = @game.players[data.id]
			if data.equipped
				player.equipItem(data.item)
			else
				player.unequipItem(data.item)

	sendUpdate: ->
		player = @game.player
		return unless player
		now.sendUpdate
			position: player.position
			voicePitch: player.voicePitch
			items: Object.keys(game.player.items)

	sendEquipUpdate: (item, equipped) ->
		now.sendEquipUpdate item, equipped
###
