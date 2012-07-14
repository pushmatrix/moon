class window.Milk
	@mixin: (target, objects...) ->
		for object in objects
			for key, value of object
				target[key] = value

		target

	mixin: (objects...) ->
		Milk.mixin this, objects...

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

	componentDispatch: (operationName, args) ->
		if @components
			for component in @components
				component::[operationName]?.apply this, args
		null

	stage: (args...) ->
		@componentDispatch 'stage', args
	render: (args...) ->
		@componentDispatch 'render', args
	update: (args...) ->
		@componentDispatch 'update', args
	exportObject: (object3D) ->
		@object3D = object3D
		@componentDispatch 'exportObject', [object3D]

	notReady: ->
		@_ready = false
		return if game.hasLoaded

		className = @constructor.name
		Milk.loadingStates ||= {}
		Milk.loadingStates[className] ||= 0
		Milk.loadingStates[className] += 1

		console.log 'LOADING', className
		l.innerHTML += "<li>Loading #{className}</li>" if l = document.getElementById('chat-log')

	ready: ->
		@_ready = true
		@onready?()
		return if game.hasLoaded

		className = @constructor.name
		Milk.loadingStates[className] -= 1

		console.log 'DONE', className
		l.innerHTML += "<li>Done #{className}</li>" if l = document.getElementById('chat-log')

		game.ready() if @isReady()

	isReady: ->
		return false if not game.isReady
		for state, count of Milk.loadingStates
			return false if count > 0

		true

	afterReady: (callback) ->
		@onready = callback
		@onready?() if @_ready

	observe: (eventName, callback) ->
		@_observers ||= {}
		c = @_observers[eventName] ||= []
		c.push callback if c.indexOf(callback) is -1
		return this

	fire: (eventName, data) ->
		c = @_observers[eventName]
		if c
			for callback in c
				callback data
		return this

class Milk.Component
	@isMilkComponent: true

class Milk.Script
	@isMilkScript: true

class Milk.Game extends Milk
	constructor: ->
		# can't call super before game is defined
		@isReady = false
		@debugOptions = window.location.hash.substr(1).split(',')

	debug: (key) ->
		@debugOptions.indexOf(key) isnt -1

	loadLevel: (levelClass) ->
		@client = new Milk.NetworkClient
		@level = new levelClass

		@isReady = true #this will prevent any synchronous notReady calls from firing ready

	ready: ->
		@hasLoaded = true
		console.log 'DONE LOADING GAME'
		setTimeout (-> document.getElementById('chat-log').innerHTML = ''), 1500
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

window.addEventListener 'load', ->
	window.game = new Milk.Game
	game.loadLevel Milk.MoonLevel



###
class Scene
	constructor: ->
		## PLAYERS
		@players = {}
		@vehicles = []

		## TARDIS
		tardis = new Vehicle.Tardis
		tardis.position = new THREE.Vector3(-20,10.5,-60)
		@addVehicle tardis

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

		if @player.position.y < (@milk.position.y - 3)
			@scene.fog.far = 20
		else
			@scene.fog.far = 100000

		for vehicle in @vehicles
			vehicle.update() if vehicle isnt @player
		for _,player of @players
			player.afterUpdate()
		@renderer.render @scene, @camera

###
