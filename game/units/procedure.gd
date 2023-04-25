extends Node

const Hand = preload("../items/hand.gd")

var speed = 0.7
var turn_speed = 0.2
@onready var _unit = get_parent()
@onready var _action = get_node("../Action")
@onready var _equipment = get_node("../Equipment")


func _ready():
	_action.bind("climb", Callable(self, "climb"))
	_action.bind("use_start", Callable(_equipment, "use_held").bind(false))
	_action.bind("use2_start", Callable(_equipment, "use_held").bind(true))


func face_front():
	var face_dir = atan2(_unit.forward.x, _unit.forward.z)
	_unit.rotation.y = lerp_angle(_unit.rotation.y, face_dir, turn_speed)


func pickup(item):
	_equipment.set_item_by_index(_equipment.get_held_index(), item)


func jump(jump_force):
	_unit.grounded = false
	_unit.velocity.y = jump_force
	var toward = _unit.get_transform().basis.z.normalized()
	var forward_vel = G.HORIZONTAL_PLANE.project(toward)
	_unit.velocity += forward_vel * 5
	_unit.animator.play("jump_start")


func climb():
	var toward = _unit.get_transform().basis.z.normalized()
	var forward_vel = G.HORIZONTAL_PLANE.project(toward)
	_unit.velocity += forward_vel


func walk(motor_forward, motor_side):
	var walk_forward = G.HORIZONTAL_PLANE.project(_unit.forward)
	var walk_right = _unit.head.get_transform().basis.x.normalized()
	_unit.motor += walk_forward * motor_forward
	_unit.motor += walk_right * motor_side
	_unit.motor = _unit.motor.normalized() * speed


func walk_cardinal(x, z):
	_unit.motor.x = x
	_unit.motor.z = z
	_unit.motor = _unit.motor.normalized() * speed


func use():
	face_front()
	var inv_item = _equipment.get_held_item()
	if inv_item != null:
		if _action.set_next("use_start", inv_item.delay):
			_unit.animator.play("swing_ready")
	else:
		_interact_hand()


func use2():
	face_front()
	var inv_item = _equipment.get_held_item()
	if inv_item != null:
		if _action.set_next("use2_start", inv_item.delay2):
			_unit.animator.play("swing_ready")
	else:
		_interact_hand()


func _interact_hand():
	if _unit.hand == null:
		_unit.hand = Hand.new()
	_unit.hand.use(_unit)
