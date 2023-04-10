extends Node

const Util = preload("res://tools/util.gd")
const Blocks = preload("../blocks/blocks.gd")
const ItemDB = preload("../items/item_db.gd")
const Pickup = preload("../items/pickup.gd")

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


# TODO Eventually invert these dependencies
@onready var _unit = get_node("../Unit")
@onready var _action = get_node("../Unit/Action")
@onready var _terrain = get_node("/root/Game/Terrain")
@onready var _camera = get_node("../View")
@onready var _hotbar = get_node("../Interface/HotBar")
@onready var _interface = get_node("../Interface")

var _pickup = null
var _terrain_tool = null


func _ready():
	_terrain_tool = _terrain.get_voxel_tool()
	_terrain_tool.channel = VoxelBuffer.CHANNEL_TYPE
	_unit.head = _camera
	_action.bind("walkU", Callable(_unit, "walk").bind(1, 0))
	_action.bind("walkUL", Callable(_unit, "walk").bind(1, -1))
	_action.bind("walkUR", Callable(_unit, "walk").bind(1, 1))
	_action.bind("walkD", Callable(_unit, "walk").bind(-1, 0))
	_action.bind("walkDL", Callable(_unit, "walk").bind(-1, -1))
	_action.bind("walkDR", Callable(_unit, "walk").bind(-1, 1))
	_action.bind("walkL", Callable(_unit, "walk").bind(0, -1))
	_action.bind("walkR", Callable(_unit, "walk").bind(0, 1))
	_action.bind("jump", Callable(_unit, "jump").bind(11))
	_action.bind("use", Callable(self, "_use"))


func _physics_process(_delta):
	_unit.forward = -_camera.get_transform().basis.z.normalized()
	if !_interface.on:
		_unit.motor = Vector3()
		if _unit._grounded:
			if Input.is_action_pressed("jump"):
				if _action.set_next("jump", 0.3):
					_unit.animator.play("jump_ready")
			else:
				_unit.action.stop("jump")
				if Input.is_action_pressed("up"):
					if Input.is_action_pressed("left"):
						_action.set_next("walkUL")
					elif Input.is_action_pressed("right"):
						_action.set_next("walkUR")
					else:
						_action.set_next("walkU")
				elif Input.is_action_pressed("down"):
					if Input.is_action_pressed("left"):
						_action.set_next("walkDL")
					elif Input.is_action_pressed("right"):
						_action.set_next("walkDR")
					else:
						_action.set_next("walkD")
				else:
					if Input.is_action_pressed("left"):
						_action.set_next("walkL")
					if Input.is_action_pressed("right"):
						_action.set_next("walkR")

			if Input.is_action_pressed("use"):
				_unit.face_front()
				var inv_item = _unit.equipment.get_held_item()
				if inv_item != null:
					if _unit.action.set_next("use", inv_item.delay):
						_unit.animator.play("swing_ready")
				else:
					_pickup_item()
			else:
				_unit.action.stop("use")
	_action.on_process(_delta)


func _use():
	var inv_item = _unit.equipment.get_held_item()
	if inv_item != null:
		inv_item.use(_unit)


func _pickup_item():
	if _pickup == null:
		_pickup = Pickup.new()
	var hits = _pickup.use(_unit)
	if !hits.is_empty():
		var _item = hits.collider.get_parent()
		var item_base = _item.get_base()
		_hotbar.pickup(item_base)
		_item.remove()


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
			_interface.display(0)
		elif Input.is_action_just_pressed("ui_inventory"):
			_interface.display(1)
		elif event.pressed:
			if _hotbar_keys.has(event.keycode):
				var slot_index = _hotbar_keys[event.keycode]
				_unit.equipment.set_held_index(slot_index)

