extends Node

const MAP_INCREMENT = 256

var unit
var noise = 0
var _newmap_offset = 0
var _frame = 0
@onready var proficiency = $Proficiency
@onready var _viewer = $VoxelViewer


func _ready():
	G.player = self
	var u = $Save.load_data()
	set_unit(u)


func load_map(p):
	if G.vars.map != p:
		if p == "#down":
			p = G.rng.pick(G.mapdata.down)
		G.stock.clean()
		G.turn.clear()
		G.set_map(p)
		_newmap_offset += MAP_INCREMENT
		G.terrain.generator.offset = Vector3i(_newmap_offset, 0, 0)
		G.terrain.generator._init()
		G.terrain.generator.post_ready()
		G.terrain.get_node("LateLoader").start(1)
		unit.position = Vector3(_newmap_offset + 64 + 15, 12, 15)
		unit.buffs.clean()
		G.ui.clear()
		G.ui.fade.color = Color.BLACK
		_viewer.position = Vector3(_newmap_offset, 0, 0)


func set_unit(p):
	G.you = p
	G.stock.remove_ai(p)
	var addon
	if unit != null:
		addon = unit.get_node("Addon")
		if unit.get_parent() != G.stock:
			if unit.get_parent() != null:
				unit.get_parent().remove_child(unit)
			G.stock.add_child(unit)
		unit.remove_child(addon)
		p.position = unit.position + Vector3()
	else:
		addon = get_node("Addon")
		remove_child(addon)
	unit = p
	unit.set_name("Unit")
	unit.faction = 1
	unit.add_child(addon)
	unit.body.set_collision_mask_value(6, false)
	$View.set_unit(unit)
	$Control.set_unit(unit)
	proficiency.set_unit(unit)
	$Interface.set_unit(unit)
	$View.zoom_distance(0)
	unit.on_mesh_set()
	unit._box_mover.set_step_climbing_enabled(false)
	unit.death.connect(on_death)


func on_death():
	var u = G.stock.make_unit(Vector3(), "rat")
	set_unit(u)


func _process(_delta):
	_frame += _delta
	if _frame >= 0.5:
		_frame -= 0.5
		noise = 0

