class Milk.MoonLevel extends Milk.Level
	constructor: ->
		super bootstrap: true

		## ENVIRONMENT
		@terrain = new Milk.MoonTerrain
		@skybox = new Milk.Skybox "public/skybox"

		unless game.debug 'nocrash'
			## MILK
			geometry = new THREE.PlaneGeometry 256, 256, 1, 1
			material = new THREE.MeshPhongMaterial ambient: 0xffffff, diffuse: 0xffffff, specular: 0xff9900, shininess: 64
			@milk = new THREE.Mesh geometry, material
			@milk.doubleSided = true
			@milk.position.y = 5

			## EARTH
			@notReady()
			geometry = new THREE.SphereGeometry 50, 20, 20
			texture = new THREE.ImageUtils.loadTexture "/public/earth.jpg", null, => @ready()
			material = new THREE.MeshLambertMaterial map: texture, color: 0xeeeeee
			@earth = new THREE.Mesh geometry, material
			@earth.position.y = 79
			@earth.position.z = 500

			## SUN
			@notReady(); textureFlare0 = THREE.ImageUtils.loadTexture "/public/lensflare0.png", null, => @ready()
			@notReady(); textureFlare2 = THREE.ImageUtils.loadTexture "/public/lensflare2.png", null, => @ready()
			@notReady(); textureFlare3 = THREE.ImageUtils.loadTexture "/public/lensflare3.png", null, => @ready()

			flareColor = new THREE.Color 0xffffff
			THREE.ColorUtils.adjustHSV flareColor, 0, -0.5, 0.5

			@sun = new THREE.LensFlare textureFlare0, 700, 0.0, THREE.AdditiveBlending, flareColor
			@sun.add textureFlare2, 512, 0.0, THREE.AdditiveBlending
			@sun.add textureFlare2, 512, 0.0, THREE.AdditiveBlending
			@sun.add textureFlare2, 512, 0.0, THREE.AdditiveBlending
			@sun.add textureFlare3, 60, 0.6, THREE.AdditiveBlending
			@sun.add textureFlare3, 70, 0.7, THREE.AdditiveBlending
			@sun.add textureFlare3, 120, 0.9, THREE.AdditiveBlending
			@sun.add textureFlare3, 70, 1.0, THREE.AdditiveBlending
			@sun.position.y = 30
			@sun.position.z = -500

		## PLAYERS
		@score = new Milk.Score
		@players = {}
		@player = new Milk.Alien(
			Milk.OverheadText
			Milk.Animation
			Milk.Movable
			Milk.Controllable
		)

		## NETWORK
		game.client.observe 'addPlayer', @addPlayer
		game.client.observe 'removePlayer', @removePlayer
		game.client.observe 'receivePlayerUpdate', @receivePlayerUpdate

		## NETWORK CHAT
		@chat = new Milk.NetworkChat
		@chat.observe 'receiveMessage', @receiveMessage
		@chat.observe 'willSendMessage', (data) =>
			data.voice = @player.voice

		@player.voice = {pitch: Math.random() * 100}

	stage: ->
		super

		@terrain.stage()
		@skybox.stage()

		unless game.debug 'nocrash'
			@scene.add @milk
			@scene.add @earth
			@scene.add @sun

		@player.stage()

		game.client.stage()
		@chat.stage()

		@score.observe 'change:milk', (count) ->
			document.getElementById('milk-count').innerHTML = count

	update: (delta) ->
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

		unless game.debug 'nocrash'
			@earth.rotation.y += 0.01
			@earth.rotation.x += 0.005
			@earth.rotation.z += 0.005

		super

	heightAtPosition: (position) ->
		@terrain.heightAtPosition position

	addPlayer: (data) =>
		player = new Milk.Alien Milk.Movable, Milk.Animation, Milk.OverheadText
		player.afterReady =>
			@players[data.id] = player

			player.stage()
			@receivePlayerUpdate data

	removePlayer: (data) =>
		player = @players[data.id]
		@scene.remove player.object3D

		@players[data.id] = null
		delete @players[data.id]

	receivePlayerUpdate: (data) =>
		@players[data.id]?.receiveNetworkUpdate data

	receiveMessage: (data) =>
		return if not message = data.message

		if not data.countedMilk and data.message.indexOf('milk') isnt -1
			@score.increase 'milk'
			data.countedMilk = true

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
