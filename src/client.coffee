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
