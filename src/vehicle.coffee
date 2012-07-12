class window.Vehicle extends Player
	enterTextShown: false
	hasEntered: false
	followDistance: 12

	canEnter: ->
		(!@hasEntered) and game.player.position.distanceToSquared(@position) < 75

	enter: (player) ->
		audio = document.createElement 'audio'
		source = document.createElement 'source'
		source.src = '/public/doctorwho.mp3'
		audio.appendChild source
		source = document.createElement 'source'
		source.src = '/public/doctorwho.ogg'
		audio.appendChild source
		audio.autoplay = true
		document.body.appendChild audio

		game.remove @enterText
		@hasEntered = true

		player.parent.remove player
		player.position.x = player.position.y = player.position.z = 0
		@add player

		return this

	jump: ->
		if not @wooshAudio
			@wooshAudio = audio = document.createElement 'audio'
			source = document.createElement 'source'
			source.src = '/public/tardis.mp3'
			audio.appendChild source
			document.body.appendChild audio

		super

	update: (delta) ->
		if @hasEntered
			@wooshAudio?[if @jumping then 'play' else 'pause']()
			super

		else if @canEnter()
			if @enterTextShown
				@enterText.positionOver this
			else
				@enterTextShown = true
				game.add @enterText
		else
			if @enterTextShown
				@enterTextShown = false
				game.remove @enterText

class Vehicle.Tardis extends Vehicle
	constructor: ->
		super

		geometry = new THREE.CubeGeometry(3, 5, 3)
		material = new THREE.MeshBasicMaterial({map: THREE.ImageUtils.loadTexture("/public/tardisFront.jpg")})
		mesh = new THREE.Mesh(geometry, material)
		@add mesh

		geometry.computeBoundingBox()
		@boundingBox = geometry.boundingBox

		@enterText = new TextObject 'press e to enter the tardis'
