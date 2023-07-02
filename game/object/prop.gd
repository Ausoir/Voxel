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


func turn_air():
	if G.tool.get_voxel(position + Vector3.LEFT) != 0:
		rotation.y = PI/2.0
	elif G.tool.get_voxel(position + Vector3.RIGHT) != 0:
		rotation.y = PI*3/2.0
	elif G.tool.get_voxel(position + Vector3.FORWARD) != 0:
		rotation.y = 0
	elif G.tool.get_voxel(position + Vector3.BACK) != 0:
		rotation.y = PI


func on_damaged(_pos: Vector3, damage: int, _inflict):
	if damage > toughness:
		G.stock.make_particle(position, "demolish")
		remove()


func on_interact(_user: Node3D):
	pass


func remove():
	queue_free()

