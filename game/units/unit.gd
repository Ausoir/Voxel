extends Node3D

signal pressed

var speed = 0.8
var motor = Vector3()
var held_item = null
var forward
var head
var size

var _aabb : AABB
var _last_velocity_y = 0
var _velocity = Vector3()
var _grounded = false
var _box_mover = VoxelBoxMover.new()

@onready var _pilot = get_parent()
@onready var animator = $Animator
@onready var _terrain = get_node("/root/Game/Terrain")
@onready var equipment = $Equipment
@onready var action = $Action


func _ready():
	_box_mover.set_collision_mask(2)
	_box_mover.set_step_climbing_enabled(true)
	size = $Body/Shape.shape.size
	_aabb = AABB(Vector3(-.2, 0, -.2), Vector3(.4, size.y - 1, .4))
	$Model/Mesh.set_mesh(load("res://assets/chr_knight.obj"))
	equipment.add_slot("armor")
	equipment.pickup(get_node("/root/Game/Items").get_item(0))
	equipment.pickup(get_node("/root/Game/Items").get_item(1))
	equipment.connect("selected", Callable(self, "_on_held_select"))


func _physics_process(delta):
	if motor.length_squared() > 0:
		rotation.y = lerp_angle(rotation.y, atan2(motor.x, motor.z), .2)
		var walk_speed = _velocity.length()
		if walk_speed > 1:
			animator.set_speed_scale(walk_speed / 4.0)
			animator.play("walk")
	elif action.action == null and animator.current_animation == "walk":
		animator.play("RESET")
	
	_velocity.x += motor.x
	_velocity.z += motor.z
	
	var motion = _velocity * delta
	var friction = .98
	
	var prev_motion = motion
	motion = _box_mover.get_motion(_pilot.get_position(), motion, _aabb, _terrain)
	if abs(motion.y) < 0.001 and prev_motion.y < -0.001:
		_grounded = true
		friction = max(0, .92 + prev_motion.y*5)
		if _last_velocity_y < -.25:
			_last_velocity_y = 0
	if abs(motion.y) > 0.001:
		_grounded = false
		_last_velocity_y = prev_motion.y
	_pilot.global_translate(motion)

	assert(delta > 0)
	_velocity.x *= friction
	_velocity.z *= friction
	_velocity.y = motion.y / delta - G.GRAVITY * delta


func jump(jump_force):
	animator.play("jump_start")
	_velocity.y = jump_force
	_grounded = false
	var toward = get_transform().basis.z.normalized()
	var forward_vel = Plane(Vector3(0, 1, 0), 0).project(toward)
	_velocity += forward_vel * 5


func walk(motor_forward, motor_side):
	var walk_forward = Plane(Vector3(0, 1, 0), 0).project(forward)
	var walk_right = head.get_transform().basis.x.normalized()
	motor += walk_forward * motor_forward
	motor += walk_right * motor_side
	motor = motor.normalized() * speed


func get_item_position():
	return $Model/Item.global_position


func face_front():
	rotation.y = lerp_angle(rotation.y, atan2(forward.x, forward.z), .2)


func _on_held_select():
	var item = equipment.get_item_by_index(equipment.get_held_index())
	var item_mesh = get_node("Model/Item")
	if item == null:
		item_mesh.hide()
	else:
		item_mesh.show()
		item_mesh.set_mesh(item.model)
