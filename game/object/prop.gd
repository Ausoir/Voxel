extends Node3D

var sid
var toughness = 0


func serialize():
	var r = {
		"name": sid,
	}
	return r

func on_damaged(_pos: Vector3, damage: int, _inflict):
	if damage > toughness:
		remove()


func remove():
	G.stock.make_particle(position, "demolish")
	queue_free()

