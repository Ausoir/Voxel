extends Node3D

const LIFETIME = 10.0

const ExplosionScene = preload("res://game/fx/explosion/explosion.tscn")

var _direction := Vector3(0, 0, 1)
var _speed := 20.0
var _remaining_time := LIFETIME


func set_direction(direction: Vector3):
	direction += Vector3(0.0001, 0.0001, 0.001) # Haaaaak
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
	
	var hit = G.tool.raycast(trans.origin, _direction, crossed_distance)
	if hit != null:
		G.tool.block_sphere(hit.position, 4.0, 0)
		G.stock.make_debris(hit.position, 24)
		G.stock.make_particle(hit.position, "explosion")

		queue_free()
			
	else:
		trans.origin += motion
		global_transform = trans
