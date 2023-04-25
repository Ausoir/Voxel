extends Node

const Util = preload("res://tools/util.gd")
const Blocks = preload("../blocks/blocks.gd")
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


@onready var _unit = get_node("../Unit")
@onready var _action = get_node("../Unit/Action")
@onready var _terrain = get_node("/root/Game/Terrain")
@onready var _camera = get_node("../View")
@onready var _interface = get_node("../Interface")
@onready var _procedure = get_node("../Unit/Procedure")

var _menu_settings = MENU_SETTINGS.instantiate()
var _menu_inventory = MENU_INVENTORY.instantiate()
var _terrain_tool = null
var _debug_mode = false


func _ready():
	_terrain_tool = _terrain.get_voxel_tool()
	_terrain_tool.channel = VoxelBuffer.CHANNEL_TYPE
	_unit.head = _camera
	_action.bind("walkU", Callable(_procedure, "walk").bind(1, 0))
	_action.bind("walkUL", Callable(_procedure, "walk").bind(1, -1))
	_action.bind("walkUR", Callable(_procedure, "walk").bind(1, 1))
	_action.bind("walkD", Callable(_procedure, "walk").bind(-1, 0))
	_action.bind("walkDL", Callable(_procedure, "walk").bind(-1, -1))
	_action.bind("walkDR", Callable(_procedure, "walk").bind(-1, 1))
	_action.bind("walkL", Callable(_procedure, "walk").bind(0, -1))
	_action.bind("walkR", Callable(_procedure, "walk").bind(0, 1))
	_action.bind("jump", Callable(_procedure, "jump").bind(11))


func _physics_process(_delta):
	_unit.forward = -_camera.get_transform().basis.z.normalized()
	if _debug_mode:
		_unit.velocity.y = 0
		_unit.velocity.x *= .97
		_unit.velocity.z *= .97
		_unit.grounded = true
	if !_interface.on:
		_unit.motor = Vector3()
		if _unit.grounded:
			if Input.is_action_pressed("jump"):
				if _debug_mode:
					_unit.velocity.y += 12
				elif _action.set_next("jump", 0.3):
					_unit.animator.play("jump_ready")
			else:
				if Input.is_action_pressed("sneak"):
					if _debug_mode:
						_unit.velocity.y -= 12
				if Input.is_action_pressed("up"):
					if Input.is_action_pressed("left"):
						_action.set_next("walkUL", 0)
					elif Input.is_action_pressed("right"):
						_action.set_next("walkUR", 0)
					else:
						_action.set_next("walkU", 0)
				elif Input.is_action_pressed("down"):
					if Input.is_action_pressed("left"):
						_action.set_next("walkDL", 0)
					elif Input.is_action_pressed("right"):
						_action.set_next("walkDR", 0)
					else:
						_action.set_next("walkD", 0)
				else:
					if Input.is_action_pressed("left"):
						_action.set_next("walkL", 0)
					if Input.is_action_pressed("right"):
						_action.set_next("walkR", 0)
			if Input.is_action_pressed("use"):
				_procedure.use()
			if Input.is_action_pressed("use2"):
				_procedure.use2()
	_action.on_process(_delta)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if !_interface.on:
			_camera.update_rotations(event.relative)
	elif event is InputEventMouseButton:
		if !_interface.on:
			if Input.is_action_just_pressed("zoom out"):
				_camera.zoom_distance(1)
			elif Input.is_action_just_pressed("zoom in"):
				_camera.zoom_distance(-1)
			elif Input.is_action_just_pressed("select next"):
				_unit.equipment.increment_held_index(1)
			elif Input.is_action_just_pressed("select previous"):
				_unit.equipment.increment_held_index(-1)
	elif event is InputEventKey:
		if Input.is_action_just_pressed("ui_menu"):
			_interface.display(_menu_settings)
		elif Input.is_action_just_pressed("ui_inventory"):
			_interface.display(_menu_inventory)
		elif Input.is_action_just_pressed("debug"):
			_debug_mode = !_debug_mode
		elif event.pressed:
			if _hotbar_keys.has(event.keycode):
				var slot_index = _hotbar_keys[event.keycode]
				_unit.equipment.set_held_index(slot_index)

