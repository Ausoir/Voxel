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
var _player_mesh
var _player_helm_mesh


func _ready():
	_offset = get_position()
	if capture_mouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func set_unit(p):
	_unit = p
	_player_mesh = _unit.get_node("Model/Body/Mesh")
	_player_helm_mesh = _unit.get_node("Model/Body/Head")


func _process(_delta):
	var offset = Vector3(0, _unit.size.y - .2, 0)
	position = _unit.position + offset


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
		_player_mesh.hide()
		_player_helm_mesh.hide()
	else:
		_player_mesh.show()
		_player_helm_mesh.show()
	update_rotations(Vector3())


