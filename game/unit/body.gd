extends CharacterBody3D

var motor = Vector3()

var collided = false
var grounded = true

@onready var _unit = get_parent()
@onready var animator = get_node("../Animator")
@onready var action = _unit.action


func _physics_process(delta):
	if motor.length_squared() > 0:
		_unit.rotation.y = lerp_angle(_unit.rotation.y, atan2(motor.x, motor.z), .2)
		var walk_speed = velocity.length()
		if walk_speed > 1:
			animator.set_speed_scale(walk_speed / 4.0)
			animator.play("walk")
	elif action.action == null and animator.current_animation == "walk":
		animator.play("RESET")

	velocity.x += motor.x
	velocity.z += motor.z
	collided = move_and_slide()
	grounded = is_on_floor()
	_unit.global_position = global_position
	position *= 0
	velocity.y -= G.GRAVITY * delta
	var friction
	if not grounded:
		friction = .97
	else:
		friction = .9
	velocity.x *= friction
	velocity.z *= friction
