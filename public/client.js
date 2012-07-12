var viewport = {
  x: 0,
  y: 300,
  msg: "",
  pitch: Math.random() * 100,
  inventory: []
}

updateActor = function() {
  now.updateActor(viewport);
}

now.ready(function() {
  updateActor();
});

now.drawActors = function(actors) { 
  // console.log(actors)
  for(var i in actors) {
    player = actors[i];
   
    //if(i == now.core.clientId) {
    context.drawImage(character, player.x, player.y, 87, 200);
    drawText(player.msg, player);
  }
  players = actors;
}
