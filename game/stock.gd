extends Node


const Item = preload("res://game/items/item.gd")
const Item_JSON = preload("res://assets/json/items.json")
const Unit_JSON = preload("res://assets/json/units.json")

var _items = {}


func _ready():
	_ready_items()


func _ready_items():
	var dict = Item_JSON.get_data()
	for itemname in dict.keys():
		var dat = dict.get(itemname)
		if dat != null:

			var item : Item
			var script = dat.get("script")
			if script != null:
				var dir = str("res://game/items", "/", script, ".gd")
				item = load(dir).new()
			else:
				item = Item.new()
			
			item.sid = itemname
			item.sprite = load("res://assets/items/" + dat.spritename + ".png")
			if dat.has("modelname"):
				item.model = load("res://assets/items/" + dat.modelname + ".obj")
			item.delay = dat.get("delay", 0)
			item.delay2 = dat.get("delay2", 0)
			item.part = dat.get("part")
			item.data = dat.get("data")
			_items[itemname] = item
			add_child(item)


func get_item(itemname):
	return _items.get(itemname)


func make_unit(pos: Vector3, itemname: String):
	var dict = Unit_JSON.get_data()
	var dat = dict.get(itemname)
	if dat != null:
		var dir = str("res://game/units", "/", itemname, "/", itemname, ".tscn")
		var item = load(dir).instantiate()
		G.objects.add_child(item)
		item.unit.sid = itemname
		var mesh = load("res://assets/units/" + dat.model + ".obj")
		item.unit.set_mesh(mesh)
		for i in dat.get("slots", []):
			item.unit.equipment.add_slot(i)
		for i in dat.get("items", []):
			item.unit.equipment.pickup(_items.get(i))
		item.position = pos
		return item
