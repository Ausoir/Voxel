extends Node3D

var sid
var toughness = 5


func serialize():
	var r = {
		"name": sid,
	}
	return r


func turn_random():
	rotation.y = randf() * PI


func on_damaged(_pos: Vector3, damage: int, _inflict):
	if damage > toughness:
		remove()


func on_interact(_user: Node3D):
	pass


func remove():
	G.stock.make_particle(position, "demolish")
	queue_free()

