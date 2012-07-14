class Milk.ChangePlayer extends Milk.Script
	constructor: (className) ->
		className = className[0].toUpperCase() + className.substr(1)
		if not Milk[className]
			throw "No player called #{className}"

		player = game.level.replacePlayerActor game.level.player, className, controllable: true, id: 'player'
		player.observe 'ready', =>
			game.level.player = player

		# now.sendPlayerUpdate actorClass: className
		now.changePlayerActor actorClass: className

Milk.Script.player = Milk.ChangePlayer
