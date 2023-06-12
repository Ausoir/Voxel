extends Node3D

@export var sensitivity = 0.4
@export var min_angle = -1.57
@export var max_angle = 1.57
@export var capture_mouse = true
@export var distance = 0.0

var _sensitivity_rad = 0
var _unit
var _yaw = 0
var _pitch = 0
var _offset = Vector3()
var _override_pos
var _box_mover = VoxelBoxMover.new()
var _aabb = AABB(Vector3(-.2, -.2, -.2), Vector3(.4, .4, .4))
var _springarm : Vector3


func _ready():
	if capture_mouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#	_box_mover.set_collision_mask(_camera.get_collision_mask())
	_sensitivity_rad = deg_to_rad(sensitivity)


func set_override(p):
	_override_pos = p


func set_unit(p):
	_unit = p


func _physics_process(_delta):
	if _override_pos != null:
		position = _override_pos
	else:
		var unit_pos = _unit.position + _offset
		if distance == 0:
			position = unit_pos
		else:
			var face = get_transform().basis.z.normalized() * distance
			var motion = _box_mover.get_motion(unit_pos, face, _aabb, G.terrain)
			_springarm = unit_pos + motion
			position = lerp(position, _springarm, 0.1)


func update_rotations(motion):
	_yaw -= motion.x * _sensitivity_rad
	_pitch += motion.y * _sensitivity_rad
	
	var e = 0.001
	if _pitch > max_angle-e:
		_pitch = max_angle-e
	elif _pitch < min_angle+e:
		_pitch = min_angle+e
	
	set_rotation(Vector3(0, _yaw, 0))
	rotate(get_transform().basis.x.normalized(), -_pitch)
	_springarm = -_unit.forward * distance


func zoom_distance(zoom):
	distance = clamp(distance + zoom * 0.5, 0, 4)
	if distance == 0:
		_unit.set_fp_visibility(false)
		_offset = Vector3(0, _unit.size.y * 2.0/3, 0)
		if _unit._healthbar != null:
			_unit._healthbar.position = Vector3(0, .1, .5)
	else:
		_unit.set_fp_visibility(true)
		_offset = Vector3(0, _unit.size.y - .2, 0)
		if _unit._healthbar != null:
			_unit._healthbar.position = Vector3(0, _unit.size.y, 0)
	update_rotations(Vector3())


