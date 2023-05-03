extends "res://game/items/prop.gd"

signal pressed


var _last_velocity_y = 0
var _box_mover = VoxelBoxMover.new()
var _aabb : AABB
var sid = "unit"
var motor = Vector3()
var forward
var head
var size
var data
var grounded = false
var velocity = Vector3()
var action = preload("./action.gd").new()
var procedure = preload("./procedure.gd").new()

@onready var animator = $Animator
@onready var _terrain = get_node("/root/Game/Terrain")


func _ready():
	_box_mover.set_collision_mask(1)
	size = $Body/Shape.shape.size
	_aabb = AABB(Vector3(-.3, 0, -.3), Vector3(.6, size.y, .6))
	procedure.on_ready(self)
#	_box_mover.set_step_climbing_enabled(true)
#	_box_mover.set_max_step_height(.5)


func set_mesh(new_mesh):
	$Model/Mesh.set_mesh(new_mesh)


func _physics_process(delta):
	if motor.length_squared() > 0:
		rotation.y = lerp_angle(rotation.y, atan2(motor.x, motor.z), .2)
		var walk_speed = velocity.length()
		if walk_speed > 1:
			animator.set_speed_scale(walk_speed / 4.0)
			animator.play("walk")
	elif action.action == null and animator.current_animation == "walk":
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

	assert(delta > 0)
	velocity.x *= friction
	velocity.z *= friction
	velocity.y = motion.y / delta - G.GRAVITY * delta
