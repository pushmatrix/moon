class Milk.Sprite extends Milk
	SCALE_FACTOR = 0.0001

	constructor: (@filename) ->
		super

		@notReady()
		@texture = THREE.ImageUtils.loadTexture @filename, null, =>
			@mesh = new THREE.Sprite map: texture, size: SCALE_FACTOR, useScreenCoordinates: false, color: 0xffffff
			@mesh.scale.x = texture.image.width * SCALE_FACTOR
			@mesh.scale.y = texture.image.height * SCALE_FACTOR

			@ready()

	render: ->
		@scene.add @mesh
