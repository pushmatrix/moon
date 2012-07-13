class window.Milk
	@mixin: (target, objects...) ->
		for object in objects
			for key, value of object
				target[key] = value

		target

	constructor: (components...) ->
		@scene = game.scene

		for component in components
			if component?.isMilkComponent
				@components ||= []
				@components.push component

				for key, value of component.prototype
					if not @[key]?
						@[key] = value

				component.call this

	componentOperation: (operationName, args) ->
		if @components
			for component in @components
				component::[operationName]?.apply this, args
		null

	stage: (args...) ->
		@componentOperation 'stage', args
	render: (args...) ->
		@componentOperation 'render', args
	update: (args...) ->
		@componentOperation 'update', args

	notReady: ->
		@_ready = false
		return if game.hasLoaded

		className = @constructor.name
		Milk.loadingStates ||= {}
		Milk.loadingStates[className] ||= 0
		Milk.loadingStates[className] += 1

		console.log 'LOADING', className
		l.append("<li>Loading #{className}</li>") if l = $('#chat-log')

	ready: ->
		@_ready = true
		@onready?()
		return if game.hasLoaded

		className = @constructor.name
		Milk.loadingStates[className] -= 1
		console.log 'DONE', className
		l.append("<li>Done #{className}</li>") if l = $('#chat-log')

		game.ready() if @isReady()

	isReady: ->
		return false if not game.isReady
		for state, count of Milk.loadingStates
			return false if count > 0

		true

	afterReady: (callback) ->
		@onready = callback
		@onready?() if @_ready

	exportObject: (@object3D) ->
		@componentOperation 'exportObject', [object3D]

class Milk.Component
	@isMilkComponent: true

class Milk.Game extends Milk
	constructor: ->
		# can't call super before game is defined
		@isReady = false

	loadLevel: (levelClass) ->
		@client = new Milk.NetworkClient
		@level = new levelClass

		@isReady = true #this will prevent any synchronous notReady calls from firing ready

	ready: ->
		@hasLoaded = true
		console.log 'DONE LOADING GAME'
		setTimeout (-> $('#chat-log').html('')), 1500
		@stage()
		@start()

	stage: ->
		@level.stage()

	antialias: true
	stats: true

	constructRenderer: ->
		return if @renderer

		if not @container
			@container = document.createElement 'div'
			document.body.appendChild @container

		@renderer = new THREE.WebGLRenderer antialias: @antialias
		@renderer.setSize window.innerWidth, window.innerHeight
		@container.appendChild @renderer.domElement

		if @stats and Stats?
			@stats = new Stats
			@stats.domElement.style.position = 'absolute'
			@stats.domElement.style.top = '0'
			@container.appendChild @stats.domElement

		window.addEventListener 'resize', =>
			width = window.innerWidth
			height = window.innerHeight
			camera = @level.camera

			camera?.aspect = width / height
			@renderer.setSize width, height
			camera?.updateProjectionMatrix()

		, false

	start: ->
		@clock = new THREE.Clock
		@constructRenderer()

		requestAnimationFrame @render, @renderer.domElement

	render: (time) =>
		delta = @clock.getDelta()
		requestAnimationFrame @render, @renderer.domElement
		timestep = (time - @lastFrameTime) * 0.001

		@stats?.update delta

		@level.update delta
		@level.render @renderer

$ ->
	window.game = new Milk.Game
	game.loadLevel Milk.MoonLevel



###
class Scene
	constructor: ->
		## PLAYERS
		@players = {}
		@vehicles = []

		## MILK
		geometry = new THREE.PlaneGeometry(256, 256, 1, 1)
		material = new THREE.MeshPhongMaterial( ambient: 0xffffff, diffuse: 0xffffff, specular: 0xff9900, shininess: 64)
		@milk = new THREE.Mesh(geometry, material)
		@milk.doubleSided = true
		@milk.position.y = 5
		@add(@milk)

		## TARDIS
		tardis = new Vehicle.Tardis
		tardis.position = new THREE.Vector3(-20,10.5,-60)
		@addVehicle tardis

		## EARTH
		@earth = new THREE.Mesh(new THREE.SphereGeometry(50,20,20), new THREE.MeshLambertMaterial(map: THREE.ImageUtils.loadTexture("/public/earth.jpg"), color: 0xeeeeee))
		@earth.position.z= 500
		@earth.position.y= 79
		@earth.rotation.y = 2.54
		@add(@earth)

		# SUN
		textureFlare0 = THREE.ImageUtils.loadTexture( "/public/lensflare0.png" )
		textureFlare2 = THREE.ImageUtils.loadTexture( "/public/lensflare2.png" )
		textureFlare3 = THREE.ImageUtils.loadTexture( "/public/lensflare3.png" )

		flareColor = new THREE.Color( 0xffffff )
		THREE.ColorUtils.adjustHSV( flareColor, 0, -0.5, 0.5 )
		@sun = new THREE.LensFlare( textureFlare0, 700, 0.0, THREE.AdditiveBlending, flareColor )
		@sun.add( textureFlare2, 512, 0.0, THREE.AdditiveBlending )
		@sun.add( textureFlare2, 512, 0.0, THREE.AdditiveBlending )
		@sun.add( textureFlare2, 512, 0.0, THREE.AdditiveBlending )

		@sun.add( textureFlare3, 60, 0.6, THREE.AdditiveBlending )
		@sun.add( textureFlare3, 70, 0.7, THREE.AdditiveBlending )
		@sun.add( textureFlare3, 120, 0.9, THREE.AdditiveBlending )
		@sun.add( textureFlare3, 70, 1.0, THREE.AdditiveBlending )
		@sun.position.x = 0
		@sun.position.y = 30
		@sun.position.z = -500
		@scene.add(@sun)

		@createRenderer()

	add: (object) ->
		@scene.add object
	remove: (object) ->
		@scene.remove object

	addPlayer: (id, position = new THREE.Vector3(7,12,-70), currentPlayer = false, items) ->
		p = new Player(id, position, items)
		@players[id] = p
		@add(p)
		if currentPlayer
			@player = p
			requestAnimationFrame @render, @renderer.domElement

	addVehicle: (object) ->
		@scene.add object
		@vehicles.push object

	enterVehicle: ->
		for vehicle in @vehicles
			if vehicle.canEnter()
				vehicle.player = @player
				@players[@player.playerId] = vehicle
				@player = vehicle.enter @player
				return

	exitVehicle: ->
		return if @player.playerId
		window.tardis = @player
		vehicle = @player
		vehicle.exit vehicle.player

		@player = vehicle.player
		@players[@player.playerId] = @player

# Uncomment for .obj loading capabilities
# THREE.Mesh.loader = new THREE.JSONLoader()

	render: (time) =>
		return unless @player

		delta = clock.getDelta()
		requestAnimationFrame @render, @renderer.domElement
		timestep = (time - @lastFrameTime) * 0.001

		@stats.update()
		@handler.update(this)

		@player.update(delta)

		mapHeightAtPlayer = @moon.getHeight(@player.position.x, @player.position.z)
		magicNumber = @player.boundingBox.max.y
		if mapHeightAtPlayer > @player.position.y - magicNumber
			@player.position.y = mapHeightAtPlayer + magicNumber
			@player.jumping = false

		target = @player.position.clone().subSelf(@player.direction().multiplyScalar(-@player.followDistance))
		@camera.position = @camera.position.addSelf(target.subSelf(@camera.position).multiplyScalar(0.1))

		mapHeightAtCamera = @moon.getHeight(@camera.position.x, @camera.position.z)
		if mapHeightAtCamera > (@player.position.y - 2)
			@camera.position.y = mapHeightAtCamera + 2
			@player.jumping = false

		@camera.lookAt(@player.position)
		@pointLight.position = @player.position.clone()
		@pointLight.position.y += 10

		if @player.position.y < (@milk.position.y - 3)
			@scene.fog.far = 20
		else
			@scene.fog.far = 100000

		for vehicle in @vehicles
			vehicle.update() if vehicle isnt @player
		for _,player of @players
			player.afterUpdate()

		@earth.rotation.y += 0.01
		@earth.rotation.z += 0.005
		@earth.rotation.x += 0.005
		@renderer.render @scene, @camera


$(document).ready ->
	window.game = new Scene
	window.client = new Client game
	window.chat = new Chat
	window.inventory = new Inventory
###
