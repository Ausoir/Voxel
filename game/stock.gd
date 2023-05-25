extends Node


const Library := preload("res://game/blocks/voxel_library.tres")
const Item = preload("res://game/items/item.gd")
const Item_JSON = preload("res://assets/json/items.json")
const Unit_JSON = preload("res://assets/json/units.json")
const Debris = preload("res://game/fx/debris.tscn")
const P_explosion = preload("res://game/fx/explosion/explosion.tscn")
const P_deflect = preload("res://game/fx/explosion/deflect.tscn")
const P_demolish = preload("res://game/fx/other/demolish.tscn")
const P_bleed = preload("res://game/fx/bleed/bleed.tscn")
const Text = preload("res://game/fx/text.tscn")
const Unit = preload("res://game/units/unit.tscn")
const Humanoid = preload("res://game/units/humanoid/humanoid.tscn")
const Underwear = preload("res://assets/units/a_underwear.obj")
const IBlank = preload("res://game/units/ai/blank.gd")
const IHuman = preload("res://game/units/ai/humanoid.gd")
var _model_cache = {}
var _scene_cache = {}


func _get_model(path: String, modelname: String):
	var model = _model_cache.get(modelname)
	if model == null:
		model = load(str("res://assets/", path, modelname, ".obj"))
		_model_cache[modelname] = model
	return model


func make_item(itemname: String):
	var dict = Item_JSON.get_data()
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
		item.model = _get_model("items/", dat.get("modelname", "bag"))
		if dat.has("model2name"):
			item.model2 = _get_model("items/", dat.model2name)
		item.drops = dat.get("drops", true)
		item.part = dat.get("part")
		item.data = dat.get("data", {}).duplicate()
		return item


func make_object(pos: Vector3, itemname: String):
	var scene = _scene_cache.get(itemname)
	if scene == null:
		var dir = str("res://game/blocks/objects/", itemname, ".tscn")
		scene = load(dir)
		_scene_cache[itemname] = scene
	var item = scene.instantiate()
	item.position = pos + G.V2_HALF
	item.rotation.y = G.tool.get_rotation_from_marker(pos) * PI/2
	add_child(item)
	return item


func make_unit(pos: Vector3, itemname: String):
	var dict = Unit_JSON.get_data()
	var data = dict.get(itemname)
	if data != null:
		var model = _get_model("units/", data.model)
		var unit = Unit.instantiate()
		unit.set_mesh(model)
		add_child(unit)
		_attach_ai(unit, data)
		unit.sid = itemname
		unit.data = data.get("data", {}).duplicate()
		unit.position = pos
		unit.health = unit.data.get("health", 1)
		return unit


func make_humanoid(parent: Node, pos: Vector3, itemname: String):
	var dict = Unit_JSON.get_data()
	var data = dict.get(itemname)
	if data != null:
		var unit = Humanoid.instantiate()
		var head_model = _get_model("items/head/", data.head)
		unit.headmesh = head_model
		unit.set_head_mesh(head_model)
		parent.add_child(unit)
		_attach_ai(unit, data)
		for i in data.slots:
			unit.equipment.add_slot(i)
		for i in data.equipments:
			unit.equipment.wear(G.stock.make_item(i))
		for i in data.items:
			unit.equipment.pickup(G.stock.make_item(i))
		unit.equipment.set_held_index(0)
		unit.sid = itemname
		unit.data = data.get("data", {}).duplicate()
		unit.position = pos
		unit.health = unit.data.get("health", 1)
		return unit


func _attach_ai(unit, data):
	var ai = data.get("ai", "blank")
	var ai_script = IBlank
	if ai == "human":
		ai_script = IHuman
	var pilot := Node.new()
	pilot.set_script(ai_script)
	unit.pilot = pilot
	unit.add_child(pilot)


func make_particle(_pos: Vector3, _particlename: String):
	var att = get("P_"+_particlename)
	if att != null:
		var particle = att.instantiate()
		particle.position = _pos
		for child in particle.get_children():
			if child is GPUParticles3D:
				child.emitting = true
		add_child(particle)


func make_text(_parent, _pos: Vector3, _text):
	var particle = Text.instantiate()
	particle.set_text(str(_text))
	particle.position = _pos
	_parent.add_child(particle)
	return particle


func make_debris(_pos: Vector3, _amount: int):
	for i in _amount:
		var debris = Debris.instantiate()
		var debris_velocity := \
			Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized()
		debris_velocity *= randf_range(5.0, 30.0)
		debris.set_velocity(debris_velocity)
		debris.position = Vector3(_pos)
		add_child(debris)

