extends Node

var unit
@onready var proficiency = $Proficiency
@onready var _viewer = $VoxelViewer


func _ready():
	G.player = self
	$Save.load_data()
	var u = G.stock.make_humanoid(self, Vector3(), G.vars.name)
	set_unit(u)


func load_map(p):
	G.stock.clean()
	G.turn.clear()
	G.vars.map = p
	_viewer.position = Vector3(256, 0, 0)
	G.terrain.generator.offset = Vector3i(256, 0, 0)
	G.terrain.generator._init()
	G.terrain.get_node("LateLoader").start(1)
	unit.global_position = Vector3(256 + 64 + 15, 12, 15)
	unit.buffs.clean()
	G.ui.clear()
	G.ui.fade.color = Color.BLACK


func set_unit(p):
	G.you = p
	var addon
	if unit != null:
		addon = unit.get_node("Addon")
		unit.queue_free()
		remove_child(unit)
	else:
		addon = get_node("Addon")
		remove_child(addon)
	unit = p
	unit.set_name("Unit")
	unit.faction = 1
	unit.add_child(addon)
	$View.set_unit(unit)
	$Control.set_unit(unit)
	proficiency.set_unit(unit)
	$Interface.set_unit(unit)
	$View.zoom_distance(0)
	unit.on_mesh_set()
