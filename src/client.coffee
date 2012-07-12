class Client
  now = window.now
  constructor: (@game) ->
    now.addPlayers = (players) =>
      for id of players
        player = players[id]
        @game.addPlayer(id, player.position, @id() == id)
        console.log "CREATING #{id}"
        console.log "I AM #{@id()}"

    now.removePlayer = (id) =>
      player = @game.players[id]
      if player
        game.scene.remove(player)
        @game.players[id] = null
        delete @game.players[id]
        

    now.updatePlayer = (player) =>
      return if player.id == @id()
      if @game.players[player.id]
        @game.players[player.id].position.x = player.position.x
        @game.players[player.id].position.y = player.position.y
        @game.players[player.id].position.z = player.position.z
        window.player = @game.players[player.id]

    setInterval @sendUpdate, 33

  id: ->
    now.core.clientId

  sendUpdate: ->
    now.sendUpdate
      position: @game.player.position
