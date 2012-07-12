class Milk.MoonLevel extends Milk.Level
	constructor: ->
		super bootstrap: true

		@terrain = new Milk.MoonTerrain
		@skybox = new Milk.Skybox "public/skybox"

	stage: ->
		super

		@terrain.stage()
		@skybox.stage()

	update: ->
		mapHeightAtCamera = @terrain.heightAtPosition @camera.position
		# if mapHeightAtCamera > @player.position.y - 2
		@camera.position.y = mapHeightAtCamera + 2


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
		@heightMap.heightAtPosition position
