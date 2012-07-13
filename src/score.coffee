class Milk.Score extends Milk
	constructor: ->
		super
		@counters = {}

	increase: (counter, amount=1) ->
		@counters[counter] ||= 0
		@fire "change:#{counter}", @counters[counter] += amount
