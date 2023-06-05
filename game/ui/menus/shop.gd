extends "res://game/ui/menus/base.gd"

const ITEMSLOT = preload("res://game/ui/inventory/item_slot.tscn")
const PRIORITY = ["healing potion", "mana potion", "arrows:24", "bullets:32", "teleport scroll"]


func _ready():
	var inventory = []
	for i in range(5):
		var itemname = PRIORITY[i]
		var item = G.stock.make_item(itemname)
		inventory.append(item)
	G.rng.set_seed(G.vars.seed + 123456)
	for _i in range(5, 32):
		var itemname = G.stock.make_group("#shop")
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
	var txt = str("[color=GOLD]Gold[/color]: ", G.vars.gold)
	G.ui.set_sidetext(txt)


func on_press(item):
	var value = _get_item_value(item)
	G.you.action.set_next("idle", .3)
	if G.vars.gold >= value:
		if !G.you.equipment.pickup(item):
			item.drop(G.you)
		G.ui.set_message(str("You buy <", item.sid, ">!"))
		G.sfx.play("buy", G.you.position)
		G.vars.gold -= value
	else:
		G.ui.set_message(str("Insufficient gold..."))
	G.ui.clear()


func _get_item_value(item):
	var arr = item.sid[0].to_utf8_buffer()[0]
	var value = item.data.get("value", 1) + ((G.vars.seed + arr) % 20)
	return value


func on_hover(item, slot):
	var dsc = item.get_description()
	var value = _get_item_value(item)
	var strval = str("\n[color=Gold]", value, " Gold[/color]")
	var pos = slot.global_position + Vector2(slot.size.x, 0)
	G.ui.set_description(dsc + strval, pos)


func on_unhover():
	G.ui.set_description(null, null)
