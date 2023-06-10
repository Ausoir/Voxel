extends Node3D

var _direction := Vector3(0, 0, 1)
var speed := 20.0
var _lifetime := 10.0
var _ss
var _ssparams
var motion
var col_mask = 8
var backstab = 2
var damage = 1
var on_attack
var shooter
var noise = 3
var inflict = []


func _ready():
	_ss = get_viewport().get_world_3d().get_direct_space_state()
	_ssparams = PhysicsRayQueryParameters3D.new()


func set_direction(direction: Vector3):
	direction += Vector3(0.0001, 0.0001, 0.001)
	_direction = direction.normalized()
	look_at(global_transform.origin + _direction, Vector3(0, 1, 0))


func _physics_process(delta: float):
	_lifetime -= delta
	if _lifetime <= 0:
		queue_free()
		return
	
	var trans = global_transform
	var crossed_distance := speed * delta
	motion = crossed_distance * _direction
	
	_ssparams.from = trans.origin
	_ssparams.to = trans.origin + motion
	_ssparams.collision_mask = col_mask
	var hit = _ss.intersect_ray(_ssparams)
	if !hit.is_empty():
		G.tool.set_sound(trans.origin, noise)
		on_collide(hit)
		on_effect(hit.position)
		queue_free()
	else:
		trans.origin += motion
		global_transform = trans


func on_collide(hit):
	var unit = hit.collider.get_parent()
	if unit.get("buffs") != null:
		if !unit.alert:
			damage += backstab
		unit.last_hitter = shooter
		unit.on_damaged(position, damage, inflict)
		if on_attack != null:
			on_attack.call(unit)


func on_effect(_pos):
	pass
