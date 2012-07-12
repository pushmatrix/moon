var express = require('express');

var app = express.createServer(); 
app.listen(process.env.PORT || 3000);
var nowjs = require("now");
var everyone = nowjs.initialize(app);
app.use("/public", express.static(__dirname + '/public'));
app.use("/lib", express.static(__dirname + '/lib'));


app.get('/', function(req,res) {
  res.sendfile('index.html');
});


var actors = {};
nowjs.on('connect', function() {
  actors[this.user.clientId] = {x: 0, y: 0, msg: ''};
});

nowjs.on('disconnect', function() {
  for(var i in actors) {
    if(i == this.user.clientId) {
      delete actors[i];
      break;
    }
  }
});

everyone.now.updateActor = function(actor) {
  actors[this.user.clientId] = actor;
  everyone.now.drawActors(actors);
}