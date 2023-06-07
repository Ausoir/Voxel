extends Node

const Hand = preload("res://game/item/hand.gd")

var speed := 0.5
var turn_speed := 0.2
var speedmod := 1.0
var hand
var _unit


func set_unit(unit):
	_unit = unit
	hand = Hand.new()


func face_front():
	var face_dir = atan2(_unit.forward.x, _unit.forward.z)
	_unit.rotation.y = lerp_angle(_unit.rotation.y, face_dir, turn_speed)


func pickup(item):
	_unit.equipment.set_item_by_index(_unit.equipment.get_held_index(), item)


func jump_ready():
	_unit.animator.play("jump_ready")


func jump(p):
	_unit.animator.play("jump")
	_unit.grounded = false
	_unit.velocity.y = p * 8
	var toward = _unit.get_transform().basis.z.normalized()
	var forward_vel = G.HORIZONTAL_PLANE.project(toward)
	_unit.velocity += forward_vel * p * 5


func climb():
	var toward = _unit.get_transform().basis.z.normalized()
	var forward_vel = G.HORIZONTAL_PLANE.project(toward)
	_unit.velocity += forward_vel


func walk(motor_forward, motor_side):
	var walk_forward = G.HORIZONTAL_PLANE.project(_unit.forward)
	var walk_right = _unit.camera.get_transform().basis.x.normalized()
	_unit.motor += walk_forward * motor_forward
	_unit.motor += walk_right * motor_side
	_unit.motor = _unit.motor.normalized() * max(0, speed) * speedmod


func walk_toward(to):
	_unit.motor.x = to.x - _unit.position.x
	_unit.motor.z = to.z - _unit.position.z
	_unit.motor = _unit.motor.normalized() * max(0, speed) * speedmod


func stop_walk():
	_unit.motor = Vector3()


func use():
	face_front()
	if _unit.action.delay <= 0:
		if !_unit.buffs.has("daze"):
			_unit.buffs.set_duration("invisibility", 0)
			speedmod = 0.5
			if _unit.get_type() == 1:
				var inv_item = _unit.equipment.get_held_item()
				if inv_item != null:
					inv_item.use(_unit)
				else:
					hand.use(_unit)
			else:
				if !hand.use(_unit):
					_unit.animator.play("tackle")


func use2():
	face_front()
	if !_unit.buffs.has("silence"):
		_unit.buffs.set_duration("invisibility", 0)
		speedmod = 0.5
		if _unit.get_type() == 1:
			var inv_item = _unit.equipment.get_held_item()
			if inv_item != null and inv_item.use2(_unit):
				return
		_unit.skills.on_ability()
