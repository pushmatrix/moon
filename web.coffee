express = require('express')

app = express.createServer()
app.listen(process.env.PORT || 3000)
nowjs = require("now")
everyone = nowjs.initialize(app)
app.use("/public", express.static(__dirname + '/public'))
app.use("/lib", express.static(__dirname + '/lib'))

app.get '/', (req,res) ->
  res.sendfile('index.html')

players = {}
nowjs.on 'connect', ->
  # Send all the existing players to the new player

  @now.welcome
    players: players

  id = @user.clientId
  player = players[''+id] = {id: id}

  # Send this new player to all existing players
  everyone.now.addPlayer player


nowjs.on 'disconnect', ->
  id = @user.clientId
  players[''+id] = null
  delete players[''+id]

  everyone.now.removePlayer {id: id}

everyone.now.sendPlayerUpdate = (data) ->
  player = players[@user.clientId]
  for key, value of data
    player[key] = value

  everyone.now.receivePlayerUpdate player

everyone.now.sendMessage = (data) ->
  data.id = @user.clientId
  everyone.now.receiveMessage data

###
everyone.now.sendUpdate = (player) ->
  players[@user.clientId] = player

  data = JSON.parse JSON.stringify player
  data.id = @user.clientId

  everyone.now.updatePlayer data

  #clientId = @user.clientId
  #everyoneButUser @user, =>
  #  @now.updatePlayer
  #    id: clientId
  #    position: player.position

everyone.now.sendMessage = (message) ->
  everyone.now.receiveMessage {id: @user.clientId, message: message}

everyone.now.sendEquipUpdate = (item, equipped) ->
  everyone.now.updateInventory {id: @user.clientId, item: item, equipped: equipped}

###
