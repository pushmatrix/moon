###
class window.Inventory
  constructor: ->
    @elem = $("#inventory")
    $("body").keydown(@keyDown)
    _this = @
    $('#inventory li').click (e) ->
      item = $(@).find("img").data("item")
      _this.toggleItem(item)

  toggle: ->
    @elem.toggle()

  toggleItem: (item) ->
    if !game.player.items[item]
      client.sendEquipUpdate(item, true)
    else
      client.sendEquipUpdate(item, false)

  keyDown: (e) =>
    if e.keyCode is 73
      @toggle()
###
