class Milk.Skybox extends Milk
	constructor: (filepath) ->
		super

		urls =
		[
		  "#{filepath}/posx.png" #pos-x
		  "#{filepath}/negx.png" #neg-x
		  "#{filepath}/posy.png" #pos-y
		  "#{filepath}/negy.png" #neg-y
		  "#{filepath}/posz.png" #pos-z
		  "#{filepath}/negz.png" #neg-z
		]

		@notReady()
		texture = THREE.ImageUtils.loadTextureCube urls, null, => @ready() if texture.image.loadCount is 6

		shader = THREE.ShaderUtils.lib.cube
		shader.uniforms.tCube.texture = texture

		@material = new THREE.ShaderMaterial
			uniforms: shader.uniforms
			vertexShader: shader.vertexShader
			fragmentShader: shader.fragmentShader
			depthWrite: false

	width: 10000
	height: 10000
	depth: 10000

	stage: ->
		geo = new THREE.CubeGeometry @width, @height, @depth, 1, 1, 1, null, true

		@mesh = new THREE.Mesh geo, @material
		@mesh.flipSided = true

		@scene.add @mesh
