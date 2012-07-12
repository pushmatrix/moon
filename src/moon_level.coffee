class Milk.MoonLevel extends Milk.Level
	constructor: ->
		super bootstrap: true

		@terrain = new Milk.MoonTerrain
		@skybox = new Milk.Skybox "public/skybox"

		@player = new Milk.Spaceman(
			Milk.Movable,
			Milk.Controllable,
			Milk.Jumpable
		)

	stage: ->
		super

		@terrain.stage()
		@skybox.stage()

		@player.stage()

	update: ->
		super

		@player.update()

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
