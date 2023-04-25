extends CharacterBody3D

var motor = Vector3()

var _weapon_callback
var _gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var _friction = 1
var collided = false

@onready var _unit = get_parent()
@onready var _pilot = _unit.get_parent()
@onready var animator = get_node("../Animator")
@onready var action = get_node("../Action")


func _physics_process(delta):
	if motor.length_squared() > 0:
		_unit.rotation.y = lerp_angle(_unit.rotation.y, atan2(motor.x, motor.z), .2)
		var walk_speed = velocity.length()
		if walk_speed > 1:
			animator.set_speed_scale(walk_speed / 4.0)
			animator.play("walk")
	elif action.action == null and animator.current_animation == "walk":
		animator.play("RESET")
	if _weapon_callback != null:
		_weapon_callback.call(self)

	velocity.x += motor.x
	velocity.z += motor.z
	collided = move_and_slide()
	_unit.grounded = is_on_floor()
	_pilot.global_position = global_position
	position *= 0
	velocity.y -= _gravity * delta
	if not _unit.grounded:
		_friction = .97
	else:
		_friction = .9
	velocity.x *= _friction
	velocity.z *= _friction
