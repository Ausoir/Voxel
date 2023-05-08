extends Node


const Library := preload("res://game/blocks/voxel_library.tres")
const Item = preload("res://game/items/item.gd")
const Item_JSON = preload("res://assets/json/items.json")
const Unit_JSON = preload("res://assets/json/units.json")
const Debris = preload("res://game/fx/explosion/debris.tscn")
const P_explosion = preload("res://game/fx/explosion/explosion.tscn")
const P_demolish = preload("res://game/fx/demolish.tscn")
const Unit = preload("res://game/units/unit.tscn")
var _items = {}
var _unit_models = {}


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
	var data = dict.get(itemname)
	if data != null:
		var modelname = data.model
		var model = _unit_models.get(modelname)
		if model == null:
			model = load(str("res://assets/units/", modelname, ".obj"))
			_unit_models[modelname] = model
		var item = Unit.instantiate()
		G.stock.add_child(item)
		item.set_mesh(model)
		item.sid = itemname
		item.position = pos
		return item


func make_particle(_pos: Vector3, _particlename: String):
	var att = get("P_"+_particlename)
	if att != null:
		var particle = att.instantiate()
		particle.position = _pos
		for child in particle.get_children():
			if child is GPUParticles3D:
				child.emitting = true
		add_child(particle)


func make_debris(_pos: Vector3, _amount: int):
	for i in _amount:
		var debris = Debris.instantiate()
		var debris_velocity := \
			Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized()
		debris_velocity *= randf_range(5.0, 30.0)
		debris.set_velocity(debris_velocity)
		debris.position = Vector3(_pos)
		add_child(debris)

