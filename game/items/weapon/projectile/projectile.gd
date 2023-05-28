extends Node3D

var _direction := Vector3(0, 0, 1)
var _speed := 20.0
var _remaining_time := 10.0
var _ss
var _ssparams
var col_mask = 12
var damage = 1


func _ready():
	_ss = get_viewport().get_world_3d().get_direct_space_state()
	_ssparams = PhysicsRayQueryParameters3D.new()


func set_direction(direction: Vector3):
	direction += Vector3(0.0001, 0.0001, 0.001)
	_direction = direction.normalized()
	look_at(global_transform.origin + _direction, Vector3(0, 1, 0))


func _physics_process(delta: float):
	_remaining_time -= delta
	if _remaining_time <= 0:
		queue_free()
		return
	
	var trans = global_transform
	var crossed_distance := _speed * delta
	var motion := crossed_distance * _direction
	
	_ssparams.from = trans.origin
	_ssparams.to = trans.origin + motion
	_ssparams.collision_mask = col_mask
	var hit = _ss.intersect_ray(_ssparams)
	if !hit.is_empty():
		on_collide(hit)
		queue_free()
	else:
		trans.origin += motion
		global_transform = trans


func on_collide(hit):
	if hit.collider.collision_layer & 4 > 0:
		var unit = hit.collider.get_parent()
		var damage_roll = G.rng.roll(1, damage)
		unit.take_hit(damage_roll)
		unit.on_damaged(hit.position)
	else:
		G.stock.make_debris(hit.position, 3)
	G.stock.make_particle(hit.position, "explosion")
