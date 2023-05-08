extends "res://game/items/prop.gd"

signal pressed


var _last_velocity_y = 0
var _box_mover = VoxelBoxMover.new()
var _aabb : AABB
var _last_pos = Vector3()
var _last_pos_set = false
var sid = "unit"
var motor = Vector3()
var forward
var camera
var size
var data
var grounded = false
var velocity = Vector3()
var action = preload("./action.gd").new()
var procedure = preload("./procedure.gd").new()

@onready var pilot = $Pilot
@onready var body = $Body
@onready var animator = $Animator
@onready var _terrain = get_node("/root/Game/Terrain")


func _ready():
	action.set_unit(self)
	_box_mover.set_collision_mask(1)
	procedure.on_ready(self)
#	_box_mover.set_step_climbing_enabled(true)
#	_box_mover.set_max_step_height(.5)


func set_mesh(new_mesh):
	$Model/Mesh.set_mesh(new_mesh)
	on_mesh_set()


func get_mesh():
	return $Model/Mesh


func on_mesh_set():
	size = $Model/Mesh.get_aabb().size + Vector3(0, .3, 0)
	$Body/Shape.shape.set_size(size)
	$Body/Shape.position.y = size.y / 2
	_aabb = AABB(Vector3(-.3, 0, -.3), Vector3(.6, size.y, .6))


func get_head():
	return position + Vector3(0, size.y - .1, 0)


func remove():
	if _last_pos_set:
		G.tool.set_voxel(_last_pos, 0)
	queue_free()


func _physics_process(delta):
	if motor.length_squared() > 0:
		rotation.y = lerp_angle(rotation.y, atan2(motor.x, motor.z), .2)
		var walk_speed = velocity.length()
		if walk_speed > 1:
			animator.play("walk", 1.0, walk_speed / 4.0)
	elif action.action == null:
		animator.play("RESET")

	velocity.x += motor.x
	velocity.z += motor.z

	var motion = velocity * delta
	var friction = .98

	var prev_motion = motion
	motion = _box_mover.get_motion(get_global_position(), motion, _aabb, _terrain)
	if abs(motion.y) < 0.001 and prev_motion.y < -0.001:
		grounded = true
		friction = max(0, .92 + prev_motion.y * 5)
		if _last_velocity_y < -.25:
			_last_velocity_y = 0
	if abs(motion.y) > 0.001:
		grounded = false
		_last_velocity_y = prev_motion.y
	if _box_mover.has_stepped_up():
		motion.y = min(.17, motion.y)
	global_translate(motion)
	
	var pos = position.floor()
	if pos != _last_pos:
		var pos_set = false
		if grounded and G.tool.get_voxel(pos) == 0:
			G.tool.set_voxel(pos, 1)
			pos_set = true
		if _last_pos_set:
			G.tool.set_voxel(_last_pos, 0)
		_last_pos = pos
		_last_pos_set = pos_set

	velocity.x *= friction
	velocity.z *= friction
	velocity.y = motion.y / delta - G.GRAVITY * delta
