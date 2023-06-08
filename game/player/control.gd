extends Node

const Blocks = preload("res://game/block/blocks.gd")
const MENU_INVENTORY = preload("res://game/ui/inventory/inventory.tscn")
const MENU_SETTINGS = preload("res://game/ui/settings.tscn")

const COLLISION_LAYER_AVATAR = 2

const _hotbar_keys = {
	KEY_1: 0,
	KEY_2: 1,
	KEY_3: 2,
	KEY_4: 3,
	KEY_5: 4,
	KEY_6: 5,
	KEY_7: 6,
	KEY_8: 7,
	KEY_9: 8
}


@onready var _camera = get_node("../Cam")
@onready var _interface = get_node("../Interface")

var _unit
var _menu_settings = MENU_SETTINGS.instantiate()
var _menu_inventory = MENU_INVENTORY.instantiate()


func set_unit(p):
	_unit = p
	_unit.camera = _camera


func _physics_process(_delta):
	_unit.forward = -_camera.get_transform().basis.z.normalized()
	if !_interface.on:
		if _unit.grounded:
			var has_moved = true
			if Input.is_action_pressed("up"):
				if Input.is_action_pressed("left"):
					_unit.procedure.walk(1, -1)
				elif Input.is_action_pressed("right"):
					_unit.procedure.walk(1, 1)
				else:
					_unit.procedure.walk(1, 0)
			elif Input.is_action_pressed("down"):
				if Input.is_action_pressed("left"):
					_unit.procedure.walk(-1, -1)
				elif Input.is_action_pressed("right"):
					_unit.procedure.walk(-1, 1)
				else:
					_unit.procedure.walk(-1, 0)
			else:
				if Input.is_action_pressed("left"):
					_unit.procedure.walk(0, -1)
				elif Input.is_action_pressed("right"):
					_unit.procedure.walk(0, 1)
				else:
					has_moved = false
			if has_moved:
				if _unit.procedure.speedmod == 1:
					G.tool.set_sound(_unit.position, 2)
				if _unit.procedure.speed < 0:
					G.ui.msg("Too heavy!")
			else:
				_unit.motor = Vector3()
				_unit.procedure.face_front()
		if _unit.action.can_set():
			if Input.is_action_pressed("use"):
				_unit.procedure.use()
			elif Input.is_action_pressed("use2"):
				_unit.procedure.use2()
			elif Input.is_action_pressed("jump"):
				if _unit.action.delay <= 0:
					if _unit.grounded or !_unit.skills.perform("wind"):
						_unit.action.set_next("jump", 999)
						_unit.procedure.jump_ready()
						_unit.action.cancelable = true
						_unit.procedure.speedmod = 0.5
			elif Input.is_action_just_released("jump"):
				if _unit.grounded:
					var time = _unit.action.get_time()
					if time < .5:
						_unit.procedure.jump(time*2)
			elif _unit.action.action != null:
				_unit.action.set_next("idle", 0)
				_unit.procedure.speedmod = 1
			else:
				_unit.procedure.speedmod = 1
	_unit.action.on_process(_delta)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if !_interface.on and _unit.action.turnable:
			_camera.update_rotations(event.relative)
	elif event is InputEventMouseButton:
		if !_interface.on:
			if Input.is_action_just_pressed("zoom out"):
				_camera.zoom_distance(1)
			elif Input.is_action_just_pressed("zoom in"):
				_camera.zoom_distance(-1)
			elif Input.is_action_just_pressed("select next"):
				if _unit.action.set_next("wield", 1, _unit.equipment.increment_held_index.bind(1)):
					_unit.animator.play("RESET")
					_unit.action.show_progress = true
				_unit.procedure.speedmod = 0.5
			elif Input.is_action_just_pressed("select previous"):
				if _unit.action.set_next("wield", 1, _unit.equipment.increment_held_index.bind(-1)):
					_unit.animator.play("RESET")
					_unit.action.show_progress = true
				_unit.procedure.speedmod = 0.5
	elif event is InputEventKey:
		if Input.is_action_just_pressed("ui_menu"):
			_interface.display(_menu_settings)
			_unit.action.set_next("wield", 0.1)
		elif Input.is_action_just_pressed("ui_inventory"):
			_interface.display(_menu_inventory)
			_unit.action.set_next("wield", 0.1)
		elif Input.is_action_just_pressed("debug"):
			if _unit.buffs.has("flight"):
				_unit.buffs.set_duration("flight", 0)
				_unit.buffs.set_duration("glow", 0)
			else:
				_unit.buffs.add("flight", -1)
				_unit.buffs.add("glow", -1)
			_unit.mana += 1
			_unit.die()
		elif event.pressed:
			if _hotbar_keys.has(event.keycode):
				var v = _hotbar_keys[event.keycode]
				if _unit.action.set_next("wield", 1, _unit.equipment.set_held_index.bind(v)):
					_unit.animator.play("RESET")
					_unit.action.show_progress = true
				_unit.procedure.speedmod = 0.5

