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
  players[this.user.clientId] = {}
  everyone.now.addPlayer(@user.clientId)

nowjs.on 'disconnect', ->
  for i in players
    if i == this.user.clientId
      delete players[i]
      break

#everyoneButUser = (user, callback) =>
#  for i of players
#    if i != user.clientId
#      console.log "sending from #{user.clientId} to #{i}"
#      nowjs.getClient i, (err) =>
#        callback()

everyone.now.sendUpdate = (player) ->
  players[this.user.clientId] = player
  everyone.now.updatePlayer
    id: @user.clientId
    position: player.position
  #clientId = @user.clientId
  #everyoneButUser @user, =>
  #  @now.updatePlayer
  #    id: clientId
  #    position: player.position