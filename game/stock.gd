extends Node


const Library := preload("res://game/block/voxel_library.tres")
const Desc_JSON = preload("res://assets/json/dialog.json")
const Item = preload("res://game/item/item.gd")
const Item_JSON = preload("res://assets/json/items.json")
const Item_Bag = preload("res://assets/item/bag.obj")
const Unit_JSON = preload("res://assets/json/units.json")
const Group_JSON = preload("res://assets/json/groups.json")
const Debris = preload("res://game/fx/debris.tscn")
const P_marker = preload("res://game/fx/other/marker.tscn")
const P_explosion = preload("res://game/fx/explosion/explosion.tscn")
const P_deflect = preload("res://game/fx/explosion/deflect.tscn")
const P_demolish = preload("res://game/fx/other/demolish.tscn")
const P_bleed = preload("res://game/fx/bleed/bleed.tscn")
const P_clarity = preload("res://game/fx/buff/clarity.tscn")
const P_dodge = preload("res://game/fx/other/dodge.tscn")
const P_summon = preload("res://game/fx/buff/summon.tscn")
const P_level = preload("res://game/fx/buff/level.tscn")
const P_spend = preload("res://game/fx/buff/spend.tscn")
const Text = preload("res://game/fx/text.tscn")
const Unit = preload("res://game/unit/unit.tscn")
const Humanoid = preload("res://game/unit/humanoid/humanoid.tscn")
const IBlank = preload("res://game/unit/ai/blank.gd")
const ISentient = preload("res://game/unit/ai/sentient.gd")
const INeutral = preload("res://game/unit/ai/neutral.gd")
const IAlly = preload("res://game/unit/ai/ally.gd")
var _model_cache = {}
var _scene_cache = {}
var _image_cache = {}
var ego_list = []
var essence_list = []


func _ready():
	load_lists()


func clean():
	for child in get_children():
		child.queue_free()
		remove_child(child)


func get_image(imgname: String):
	var sprite = _image_cache.get(imgname)
	if sprite == null:
		var path = str("res://assets/", imgname, ".png")
		if !ResourceLoader.exists(path):
			return null
		sprite = load(path)
		_image_cache[imgname] = sprite
	return sprite


func _get_model(modelname: String):
	var model = _model_cache.get(modelname)
	if model == null:
		model = load(str("res://assets/", modelname, ".obj"))
		_model_cache[modelname] = model
	return model


func get_desc(p: String):
	var dict = Desc_JSON.get_data()
	return dict.get(p)


func load_lists():
	var dict = Item_JSON.get_data()
	for key in dict.keys():
		var dat = dict[key]
		if "part" in dat and dat.part == "essence":
			essence_list.append(key)
			var ego = dat.data.get("essence")
			if ego != null:
				ego_list.append(ego)


func make_item(itemname: String):
	var dict = Item_JSON.get_data()
	var split = itemname.split(":")
	var dat = dict.get(split[0])
	if dat != null:
		var item : Item
		var script = dat.get("script")
		if script != null:
			var dir = str("res://game/item", "/", script, ".gd")
			item = load(dir).new()
		else:
			item = Item.new()
		item.sprite = get_image(dat.spritename)
		if dat.has("modelname"):
			item.model = _get_model(dat.modelname)
		else:
			item.model = Item_Bag
		if dat.has("model2name"):
			item.model2 = _get_model(dat.model2name)
		item.part = dat.get("part")
		item.data = dat.get("data", {}).duplicate()
		if !("value" in item.data):
			item.data["value"] = 1
		if split.size() > 1:
			var sd = int(split[1])
			if sd == -1:
				sd = G.rng.get_item_seed()
				itemname = str(split[0], ":", sd)
			item.imbue(sd)
		item.sid = itemname
		return item


func make_object(pos: Vector3, itemname: String):
	var scene = _scene_cache.get(itemname)
	if scene == null:
		var dir = str("res://game/object/", itemname, ".tscn")
		scene = load(dir)
		_scene_cache[itemname] = scene
	var item = scene.instantiate()
	item.position = pos
	item.rotation.y = G.tool.get_rotation_from_marker(pos) * PI/2
	add_child(item)
	return item


func make_any_unit(parent: Node, pos: Vector3, itemname: String, custom=null):
	var r = make_humanoid(parent, pos, itemname, custom)
	if r == null:
		r = make_unit(pos, itemname, custom)
	return r


func make_unit(pos: Vector3, itemname: String, custom_data=null):
	var dict = Unit_JSON.get_data()
	var data = dict.get(itemname)
	if data != null:
		var unit = Unit.instantiate()
		unit.sid = itemname
		var rawdata = data.duplicate()
		unit.data = data.get("data", {}).duplicate()
		if custom_data != null:
			rawdata.merge(custom_data, true)
			unit.data.merge(custom_data.data, true)
		add_child(unit)
		var model = _get_model(data.model)
		unit.set_mesh(model)
		unit.position = pos
		unit.faction = data.get("faction", 2)
		unit.health = unit.data.get("health", 1)
		unit.mana = unit.data.get("mana", 0)
		if !("mana" in unit.data):
			unit.data["mana"] = unit.mana
		unit.defense = unit.data.get("defense", 0)
		unit.proficiency.unserialize(unit.data.get("proficiency"))
		if "speed" in unit.data:
			unit.procedure.speed = unit.data.speed
		for i in rawdata.get("ego", []):
			unit.essence.append(i)
		unit.buffs.unserialize(unit.data.get("buffs", []))
		attach_ai(unit, rawdata.get("ai", ""))
		unit.turn_random()
		return unit


func make_humanoid(parent: Node, pos: Vector3, itemname: String, custom_data=null):
	var dict = Unit_JSON.get_data()
	var data = dict.get(itemname)
	if data != null and "head" in data:
		var unit = Humanoid.instantiate()
		var rawdata = data.duplicate()
		unit.data = data.get("data", {}).duplicate()
		if custom_data != null:
			rawdata.merge(custom_data, true)
			unit.data.merge(custom_data.data, true)
		var head_model = _get_model(rawdata.head)
		unit.headmesh = head_model
		unit.set_head_mesh(head_model)
		unit.faction = data.get("faction", 2)
		unit.health = unit.data.get("health", 1)
		unit.mana = unit.data.get("mana", 0)
		if !("mana" in unit.data):
			unit.data["mana"] = unit.mana
		unit.defense = unit.data.get("defense", 0)
		if "speed" in unit.data:
			unit.procedure.speed = unit.data.speed
		parent.add_child(unit)
		var body_model = _get_model(rawdata.body)
		unit.bodymesh = body_model
		unit.set_mesh(body_model)
		for i in rawdata.slots:
			unit.equipment.add_slot(i)
		for i in rawdata.equipments:
			unit.equipment.wear(make_item(i))
		for i in rawdata.items:
			unit.equipment.pickup(make_item(i))
		for i in rawdata.souls:
			unit.equipment.absorb(make_item(i))
		unit.equipment.set_held_index(0)
		unit.buffs.unserialize(unit.data.get("buffs", []))
		unit.proficiency.unserialize(unit.data.get("proficiency"))
		unit.sid = itemname
		unit.position = pos
		attach_ai(unit, rawdata.get("ai", ""))
		unit.turn_random()
		return unit


func attach_ai(unit, ai):
	if unit.pilot != null:
		unit.pilot.queue_free()
	var ai_script = ISentient
	if ai == "blank":
		ai_script = IBlank
	elif ai == "neutral":
		ai_script = INeutral
	elif ai == "ally":
		ai_script = IAlly
		unit.perceived(false)
		unit.faction = 1
		unit.data.erase("loot")
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

func make_group_surely(itemname):
	var r = make_group(itemname)
	if r == null:
		return make_group_surely(itemname)
	return r


func make_group(itemname):
	var dict = Group_JSON.get_data()
	var data = dict.get(itemname)
	if data != null:
		var r = G.rng.get_combo(data)
		if r != null and r[0] == "#":
			return make_group(r)
		else:
			return r


func make_any(_pos, itemname):
	if itemname != null:
		if itemname[0] == "#":
			return make_any(_pos, make_group(itemname))
		else:
			return make_any_unit(self, _pos, itemname)

