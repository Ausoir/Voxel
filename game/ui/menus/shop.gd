extends "res://game/ui/menus/base.gd"

const ITEMSLOT = preload("res://game/ui/inventory/item_slot.tscn")


func _ready():
	var inventory = []
	for _i in range(32):
		var itemname = G.stock.make_group("#shop", G.rng.arb_rf(G.vars.seed + _i))
		if itemname != null:
			var item = G.stock.make_item(itemname)
			inventory.append(item)
	var inventory_size = inventory.size()
	for _idx in range(32):
		var new = ITEMSLOT.instantiate()
		$Panel/VBox/GridContainer.add_child(new)
		if _idx < inventory_size:
			var item = inventory[_idx]
			new.set_item(item)
			new.set_selected(false)
			new.pressed.connect(on_press.bind(item))
			new.connect("mouse_entered", Callable(self, "on_hover").bind(item, new))
			new.connect("mouse_exited", Callable(self, "on_unhover"))


func on_display():
	G.ui.set_sidetext("[color=GOLD]Gold[/color]: 0")


func on_press(item):
	var arr = item.sid[0].to_utf8_buffer()[0]
	var value = item.data.get("value", 1) + (G.vars.seed + arr % 20)
	if G.vars.gold >= value:
		item.drop(G.you)
		G.ui.set_message(str("You bought ", item.sid, "!"))
		G.vars.gold -= value
	else:
		G.ui.set_message(str("Insufficient gold..."))
	G.ui.clear()


func on_hover(item, slot):
	var dsc = item.get_description()
	var pos = slot.global_position + Vector2(slot.size.x, 0)
	G.ui.set_description(dsc, pos)


func on_unhover():
	G.ui.set_description(null, null)
