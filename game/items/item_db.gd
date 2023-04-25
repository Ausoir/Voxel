extends Node

const ROOT = "res://game/items"

const Item = preload("./item.gd")


var _items := []


func _init():
	_create_item({
		"name": "rocket_launcher",
		"spritename": "eblade",
		"modelname": "eblade-0-blade",
		"behavior": "rocket_launcher.gd",
		"delay": 1,
	})
	_create_item({
		"name": "flier",
		"spritename": "flier",
		"modelname": "flier-0-flier",
		"behavior": "flier.gd",
		"delay": 1,
	})


func get_item(id: int) -> Item:
	assert(id >= 0)
	return _items[id]


func _create_item(d: Dictionary):
	var dir = str(ROOT, "/", d.name, "/")
	
	var item : Item
	if d.has("behavior"):
		var behavior_script = load(str(dir, d.name, ".gd"))
		item = behavior_script.new()
	else:
		item = Item.new()
	
	item.id = len(_items)
	item.sid = d.name
	item.sprite = load("res://assets/items/" + d.spritename + ".png")
	if d.has("modelname"):
		item.model = load("res://assets/items/" + d.modelname + ".obj")
	item.delay = d.get("delay", 0)
	item.delay2 = d.get("delay2", 0)
	_items.append(item)
	add_child(item)
