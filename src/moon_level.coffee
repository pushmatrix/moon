class Milk.MoonLevel extends Milk.Level
	constructor: ->
		super bootstrap: true

		@terrain = new Milk.MoonTerrain
		@skybox = new Milk.Skybox "public/skybox"

		@players = {}
		@player = new Milk.Alien(
			Milk.OverheadText
			Milk.Animation
			Milk.Movable
			Milk.Controllable
			Milk.Network
		)

		game.client.observe 'addPlayer', @addPlayer
		game.client.observe 'removePlayer', @removePlayer
		game.client.observe 'receivePlayerUpdate', @receivePlayerUpdate

		@chat = new Milk.NetworkChat
		@chat.observe 'receiveMessage', @receiveMessage
		@chat.observe 'willSendMessage', (data) =>
			data.voice = @player.voice

		@player.voice = {pitch: Math.random() * 100}

	stage: ->
		super

		@terrain.stage()
		@skybox.stage()

		@player.stage()

		@chat.stage()

	update: (delta) ->
		super

		@chat.update delta

		@player.update delta
		for id, player of @players
			player.update delta

		# CAMERA
		target = @player.object3D.position.clone().subSelf(@player.direction().multiplyScalar(-@player.followDistance))
		@camera.position = @camera.position.addSelf(target.subSelf(@camera.position).multiplyScalar(0.1))

		mapHeightAtCamera = @terrain.heightAtPosition @camera.position
		if mapHeightAtCamera > @player.object3D.position.y - 2
			@camera.position.y = mapHeightAtCamera + 2

		@camera.lookAt @player.object3D.position
		@pointLight.position = @player.object3D.position.clone()
		@pointLight.position.y += 10

	heightAtPosition: (position) ->
		@terrain.heightAtPosition position

	addPlayer: (data) =>
		player = new Milk.Spaceman Milk.Movable, Milk.OverheadText
		player.afterReady =>
			@players[''+data.id] = player

			player.stage()
			@receivePlayerUpdate data

	removePlayer: (data) =>
		player = @players[data.id]
		@scene.remove player.object3D

		@players[data.id] = null
		delete @players[data.id]

	receivePlayerUpdate: (data) =>
		player = @players[data.id]

		if data.position
			player.yVelocity = 0
			player.object3D.position.x = data.position.x
			player.object3D.position.y = data.position.y
			player.object3D.position.z = data.position.z

	receiveMessage: (data) =>
		return if not message = data.message

		player = if data.self then @player else @players[data.id]
		player.voice = data.voice if data.voice
		player.setText(message)
		player.stageText()

		if player.speechTimeout
			clearTimeout player.speechTimeout
			player.speechTimeout = null

		if @currentSpeech
			currentPlayer = @currentSpeech.player
			currentMessage = @currentSpeech.message
			currentPlayer.speechTimeout = setTimeout (-> currentPlayer.clearText(currentMessage)), 1000

		@currentSpeech = {player: player, message: message}
		speak.play message, player.voice || {}, =>
			@currentSpeech = null
			player.clearText(message)

class Milk.MoonTerrain extends Milk
	constructor: ->
		super

		@heightMap = new Milk.HeightMap "public/map.jpg"

		@notReady()
		@texture = THREE.ImageUtils.loadTexture "public/dirt.jpg", null, => @ready()
		@texture.wrapS = @texture.wrapT = THREE.RepeatWrapping
		@texture.repeat.set 10, 10

		@material = new THREE.MeshLambertMaterial
			map: @texture
			shading: THREE.SmoothShading
			specular: 0x0
			ambient: 0xeeeeee
			diffuse: 0x0
			color: 0x555555
			shininess: 32

	stage: ->
		geo = @heightMap.stage()

		@mesh = new THREE.Mesh geo, @material
		@scene.add @mesh

	heightAtPosition: (position) ->
		@heightMap.heightAtPosition position.x, position.z
