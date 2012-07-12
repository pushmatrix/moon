class Milk.Level extends Milk
	constructor: (options) ->
		game.scene = new THREE.Scene
		super

		return if not options?.bootstrap
		@bootstrapped = true

		fov = 50
		aspect = window.innerWidth / window.innerHeight
		near = 1
		far = 100000
		@camera = new THREE.PerspectiveCamera fov, aspect, near, far

		@sunLight = new THREE.DirectionalLight
		@pointLight = new THREE.PointLight 0x666666
		@ambientLight = new THREE.AmbientLight 0x222222

		@fog = new THREE.Fog 0x0, 1, 10000

	stage: ->
		return if not @bootstrapped

		@scene.add @camera

		@scene.add @sunLight
		@scene.add @ambientLight
		@scene.add @pointLight

		@scene.fog = @fog

	render: (renderer) ->
		return if not @bootstrapped
		renderer.render @scene, @camera
