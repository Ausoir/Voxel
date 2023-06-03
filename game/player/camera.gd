extends SpringArm3D

@export var sensitivity = 0.4
@export var min_angle = -90
@export var max_angle = 90
@export var capture_mouse = true
@export var distance = 0.0

var _unit
var _yaw = 0
var _pitch = 0
var _offset = Vector3()
var _override_pos


func _ready():
	if capture_mouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func set_override(p):
	_override_pos = p


func set_unit(p):
	_unit = p


func _process(_delta):
	if _override_pos != null:
		position = _override_pos
	else:
		position = _unit.position + _offset


func update_rotations(motion):
	_yaw -= motion.x * sensitivity
	_pitch += motion.y * sensitivity
	
	var e = 0.001
	if _pitch > max_angle-e:
		_pitch = max_angle-e
	elif _pitch < min_angle+e:
		_pitch = min_angle+e
	
	set_rotation(Vector3(0, deg_to_rad(_yaw), 0))
	rotate(get_transform().basis.x.normalized(), -deg_to_rad(_pitch))
	set_length(distance)


func zoom_distance(zoom):
	distance = clamp(distance + zoom * 0.5, 0, 5)
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


