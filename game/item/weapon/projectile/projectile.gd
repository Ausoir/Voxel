extends Node3D

var _direction := Vector3(0, 0, 1)
var speed := 20.0
var _remaining_time := 10.0
var _ss
var _ssparams
var col_mask = 12
var damage = 1
var on_attack
var inflict = []


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
	var crossed_distance := speed * delta
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
	if hit.collider.collision_layer & 8 > 0:
		var unit = hit.collider.get_parent()
		unit.on_damaged(position, damage, [])
		if on_attack != null:
			on_attack.call(unit)
	else:
		G.stock.make_debris(hit.position, 3)
	G.stock.make_particle(hit.position, "explosion")
