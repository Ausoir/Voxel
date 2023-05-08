extends SpringArm3D

@export var sensitivity = 0.4
@export var min_angle = -90
@export var max_angle = 90
@export var capture_mouse = true
@export var distance = 0.0

var _yaw = 0
var _pitch = 0
var _offset = Vector3()

@onready var _unit = get_node("../Unit")
@onready var _player_mesh = get_node("../Unit/Model/Body/Mesh")
@onready var _player_helm_mesh = get_node("../Unit/Model/Body/Helm")


func _ready():
	_offset = get_position()
	if capture_mouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	zoom_distance(0)


func _process(_delta):
	var offset = Vector3(0, _unit.size.y - .2, 0)
	position = _unit.position + offset
	DDD.set_text("position", _unit.global_position)


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


