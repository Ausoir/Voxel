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
		G.sfx.fade_bgm()
		G.set_map(p)
		var on_load = G.mapdata.get("on_load")
		if on_load != null:
			G.run_script(on_load[0], on_load[1])
		_map_time = 0
		G.vars.shop = 0
		G.ui.msg(str("Now entering: [b][color=TEAL][url=",p,"]The ", p.capitalize(), "[/url][/color][/b]"))
		G.terrain.get_node("LateLoader").stop()
		G.stock.clean()
		G.turn.clear()
		_newmap_offset += MAP_INCREMENT
		G.terrain.generator.offset = Vector3i(_newmap_offset, 0, 0)
		G.terrain.get_node("LateLoader").start(1)
		unit.position = Vector3(_newmap_offset + 32, 13, 32)
		G.ui.clear()
		G.ui.fade.color = Color.BLACK
		_viewer.position = Vector3(_newmap_offset, 0, 0)
		G.turn.add(unit.buffs.on_turn)
		G.you.buffs.add("hunger", -1)
		G.you.mana = G.you.data.mana
		if G.mapdata.get("safe", false):
			G.vars.day += 1
			G.you.buffs.add("stunted", -1)
			G.files.save_player_data()
			var u = G.files.load_player_data()
			set_unit(u)
		else:
			G.you.buffs.set_duration("stunted", 0)


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
		unit.attacked.disconnect(on_attacked)
		p.position = unit.position + Vector3()
		$Interface.unset_unit(unit)
	else:
		addon = get_node("Addon")
		remove_child(addon)
	if "sight" in p.data:
		var sight = addon.get_node("Sight")
		sight.omni_range = p.data.sight
	p.get_parent().remove_child(p)
	add_child(p)
	unit = p
	unit.set_name("Unit")
	unit.faction = 1
	unit.add_child(addon)
	unit.show_healthbar()
	$Cam.set_unit(unit)
	$Control.set_unit(unit)
	$Interface.set_unit(unit)
	$Cam.zoom_distance(0)
	unit.on_mesh_set()
	unit._box_mover.set_step_climbing_enabled(false)
	unit.death.connect(on_death)
	unit.attacked.connect(on_attacked)
	unit.alert = true
	unit.position.y = 64


func on_attacked(_dmg):
	if unit.health == 1 and G.vars.map == "dungeons" and G.vars.get("phase", 0) != 1:
		G.sfx.play_bgm("dungeons")
		G.vars["phase"] = 1


func on_death():
	G.sfx.fade_bgm()
	$Cam.zoom_distance(2)
	$Timer.start(2)
	if !unit.buffs.has("track"):
		G.files.clear_player_data()


func _on_timer_timeout():
	G.ui.animation.stop()
	G.ui.animation.seek(0, true)
	G.ui.animation.play("respawn")
	G.ui.on = true
	if unit.buffs.has("track"):
		unit.equipment.clear(true, false)
		unit.proficiency.floor_all()
		unit.data["level"] = floor(unit.data.get("level", 1))
		G.ui.msg("The chaplain revives you!")
		load_map("camp")
		unit.revive()
		G.files.save_player_data()
	else:
		G.clear()
		var root = get_tree().get_root()
		root.remove_child(root.get_node("Game"))
		var next_level_resource = load("res://game/start.tscn")
		var next_level = next_level_resource.instantiate()
		root.add_child(next_level)
		queue_free()

