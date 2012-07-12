class window.Vehicle extends Player
	enterTextShown: false
	hasEntered: false

	canEnter: ->
		(!@hasEntered) and game.player.position.distanceToSquared(@position) < 75

	enter: (player) ->
		game.remove @enterText
		@hasEntered = true

		player.parent.remove player
		player.position.x = player.position.y = player.position.z = 0
		@add player

		return this

	update: (delta) ->
		if @hasEntered
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
