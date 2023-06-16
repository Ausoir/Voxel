extends "res://game/ui/menus/base.gd"

const ITEMSLOT = preload("res://game/ui/inventory/item_slot.tscn")
const PRIORITY = ["healing potion", "mana potion", "arrows:24", "bullets:32", "meat"]
var on_set


func _ready():
	G.rng.set_seed(G.vars.seed + 987654)
	var inventory = []
	for i in range(5):
		var itemname = PRIORITY[i]
		var item = G.stock.make_item(itemname)
		inventory.append(item)
	for _i in range(5, 32):
		var itemname = G.stock.make_group("#shop")
		if itemname != null:
			var item = G.stock.make_item(itemname)
			inventory.append(item)
	var inventory_size = inventory.size()
	var sold_outs = int(G.vars.shop)
	for _idx in range(32):
		var new = ITEMSLOT.instantiate()
		$Panel/VBox/GridContainer.add_child(new)
		if _idx < inventory_size:
			var bit = 1 << _idx
			if sold_outs & bit == 0:
				var item = inventory[_idx]
				new.set_item(item)
				new.set_selected(false)
				new.pressed.connect(on_press.bind(item, _idx))
				new.mouse_entered.connect(on_hover.bind(item, new, _idx))
				new.mouse_exited.connect(on_unhover)


func on_display():
	var txt = str("[color=GOLD]Gold[/color]: ", G.vars.gold)
	G.ui.set_sidetext(txt)


func on_press(item, idx):
	if item != null:
		var value = _get_item_value(item, idx)
		G.you.action.set_next("idle", .3)
		if G.vars.gold >= value:
			if !G.you.equipment.pickup(item):
				item.drop(G.you)
			G.ui.msg(str("You buy <", item.get_display_name().capitalize(), ">!"))
			G.sfx.play("buy", G.you.position)
			G.vars.gold -= value
			if on_set != null:
				on_set.call(idx)
		else:
			G.ui.msg(str("Insufficient gold..."))
		G.ui.clear()


func _get_item_value(item, idx):
	G.rng.set_seed(G.vars.seed * G.vars.day + 77112 * idx)
	var mult = G.rng.rf() + 0.6
	var value = int(item.data.get("value", 1) * mult)
	return value


func on_hover(item, slot, idx):
	if item != null:
		var dsc = item.get_description()
		var value = _get_item_value(item, idx)
		var strval = str("\n[color=Gold]", value, " Gold[/color]")
		var pos = slot.global_position + Vector2(slot.size.x, 0)
		G.ui.set_description(dsc + strval, pos)


func on_unhover():
	G.ui.set_description(null, null)
