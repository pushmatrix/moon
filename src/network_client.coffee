class Milk.NetworkClient extends Milk
	constructor: ->
		super
		@players = {}
		@callbacks = {}

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
			for key, value of data
				player[key] = value

			@fire 'receivePlayerUpdate', player

	id: -> now.core.clientId

	observe: (eventName, callback) ->
		c = @callbacks[eventName] ||= []
		c.push callback if c.indexOf(callback) is -1

	fire: (eventName, data) ->
		c = @callbacks[eventName]
		if c
			for callback in c
				callback data

class Milk.Network extends Milk.Component
	UPDATE_INTERVAL = 30

	queueUpdate: ->
		return if @networkUpdateTimer
		@networkUpdateTimer = setTimeout (=> @networkUpdateTimer = null; @updateNetwork()), UPDATE_INTERVAL

###
class Client
  now = window.now
  constructor: (@game) ->
    now.addPlayers = (players) =>
      for id of players
        player = players[id]
        @game.addPlayer(id, player.position, @id() == id, player.items)
        console.log "CREATING #{id}"
        console.log "I AM #{@id()}"

    now.removePlayer = (id) =>
      player = @game.players[id]
      if player
        game.scene.remove(player)
        @game.players[id] = null
        delete @game.players[id]

    now.updateInventory = (data) =>
      player = @game.players[data.id]
      if data.equipped
        player.equipItem(data.item)
      else
        player.unequipItem(data.item)

    now.updatePlayer = (data) =>
      return if data.id == @id()
      if player = @game.players[data.id]
        player.position.x = data.position.x
        player.position.y = data.position.y
        player.position.z = data.position.z
        player.voicePitch = data.voicePitch

    now.receiveMessage = (data) =>
      chat.receiveMessage data

    setInterval @sendUpdate, 33

  id: ->
    now.core.clientId

  sendUpdate: ->
    player = @game.player
    return unless player
    now.sendUpdate
      position: player.position
      voicePitch: player.voicePitch
      items: Object.keys(game.player.items)

  sendMessage: (message) ->
    now.sendMessage message

  sendEquipUpdate: (item, equipped) ->
    now.sendEquipUpdate item, equipped
###
