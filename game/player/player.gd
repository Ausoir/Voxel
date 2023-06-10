extends Node

const MAP_INCREMENT = 256

var unit
var noise = 0
var _newmap_offset = 0
var _map_time = 0
var enemies = []
@onready var _viewer = $VoxelViewer


func _ready():
	G.player = self
	var u = G.files.load_player_data()
	set_unit(u)


func load_map(p):
	if G.vars.map != p:
		G.sfx.fade_bgm(p)
		G.set_map(p)
		_map_time = 0
		G.ui.msg(str("Now entering: [b][color=TEAL][url=",p,"]The ", p.capitalize(), "[/url][/color][/b]"))
		G.terrain.get_node("LateLoader").stop()
		if p == "#down":
			p = G.rng.pick(G.mapdata.down)
		G.stock.clean()
		G.turn.clear()
		_newmap_offset += MAP_INCREMENT
		G.terrain.generator.offset = Vector3i(_newmap_offset, 0, 0)
		G.terrain.generator.post_ready()
		G.terrain.get_node("LateLoader").start(1)
		unit.position = Vector3(_newmap_offset + 32, 13, 32)
		G.ui.clear()
		G.ui.fade.color = Color.BLACK
		_viewer.position = Vector3(_newmap_offset, 0, 0)
		G.turn.add(unit.buffs.on_turn)
		if p == "camp":
			G.vars.day += 1
			G.files.save_player_data()


func set_unit(p):
	G.you = p
	G.stock.attach_ai(p, "blank")
	var addon
	if unit != null:
		addon = unit.get_node("Addon")
		if unit.get_parent() != G.stock:
			if unit.get_parent() != null:
				unit.get_parent().remove_child(unit)
			G.stock.add_child(unit)
		unit.remove_child(addon)
		unit.death.disconnect(on_death)
		p.position = unit.position + Vector3()
		$Interface.unset_unit(unit)
	else:
		addon = get_node("Addon")
		remove_child(addon)
	unit = p
	unit.set_name("Unit")
	unit.faction = 1
	unit.add_child(addon)
	unit.take_hit(0)
	$Cam.set_unit(unit)
	$Control.set_unit(unit)
	$Interface.set_unit(unit)
	$Cam.zoom_distance(0)
	unit.on_mesh_set()
	unit._box_mover.set_step_climbing_enabled(false)
	unit.death.connect(on_death)
	unit.alert = true
	unit.position.y = 64


func on_death():
	G.sfx.fade_bgm()
	$Cam.zoom_distance(2)
	$Timer.start(2)


func _on_timer_timeout():
	G.ui.animation.stop()
	G.ui.animation.seek(0, true)
	G.ui.animation.play("respawn")
	G.ui.on = true
	if unit.buffs.has("track"):
		if unit.get_type() == 1:
			unit.equipment.clear(true, false)
		unit.proficiency.floor_all()
		unit.data["level"] = floor(unit.data.get("level", 1))
		G.ui.msg("The chaplain revives you!")
		load_map("camp")
		unit.revive()
		G.files.save_player_data()
	else:
		G.files.clear_player_data()
		G.clear()
		var root = get_tree().get_root()
		root.remove_child(root.get_node("Game"))
		var next_level_resource = load("res://game/start.tscn")
		var next_level = next_level_resource.instantiate()
		root.add_child(next_level)
		queue_free()

