class Client
  now = window.now
  constructor: (@game) ->
    now.addPlayer = (id) =>
      console.log ("PLAYER ADDED!!!!")
      @game.addPlayer(id, @id() == id)
      console.log "I AM #{@id()}"

    now.updatePlayer = (player) =>
      return if player.id == @id()
      if @game.players[player.id]
        console.log "ok"
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
