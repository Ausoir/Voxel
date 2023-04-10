extends Node

const Item = preload("res://game/items/floor_item.tscn")

var id := 0
var sid := ""
var sprite : Texture2D
var model : Mesh
var size = 1
var delay = 0
var data = {}


func use(_user: Node3D):
	_user.animator.play("swing_start")


func get_pointed_item(_user):
	var origin = _user.head.get_global_transform().origin
	var space_state = _user.get_viewport().get_world_3d().get_direct_space_state()
	var params = PhysicsRayQueryParameters3D.new()
	params.collision_mask = 4
	params.set_from(origin)
	params.set_to(origin + _user.forward * 20)
	params.set_collide_with_bodies(false)
	params.set_collide_with_areas(true)
	var hits = space_state.intersect_ray(params)
	return hits


func get_pointed_voxel(_user):
	var origin = _user.head.global_position
	var hit = G.tool.raycast(origin, _user.forward, 10)
	return hit


func get_user_voxel(_user):
	var origin = _user.get_global_transform().origin
	var hit = G.tool.raycast(origin, Vector3.DOWN, 10)
	return hit


func drop(_user):
	var user_pos = get_user_voxel(_user)
	if user_pos != null:
		var floor_item = Item.instantiate()
		floor_item.position = user_pos.previous_position
		floor_item.set_item(self)
		G.items.add_child(floor_item)
