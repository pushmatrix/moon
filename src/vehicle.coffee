class window.Vehicle extends THREE.Object3D

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
		@enterTextShown = false

	update: ->
		if game.player.position.distanceToSquared(@position) < 75
			if @enterTextShown
				@enterText.positionOver this
			else
				@enterTextShown = true
				game.add @enterText
		else
			if @enterTextShown
				@enterTextShown = false
				game.remove @enterText
