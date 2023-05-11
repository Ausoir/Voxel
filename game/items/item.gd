extends Node

const Item = preload("res://game/items/prop_item.tscn")

var sid := ""
var sprite : Texture2D
var model : Mesh
var model2
var drops = true
var size = 1
var delay = 0
var delay2 = 0
var part
var data = {}
var callback = Callable(self, "use_callback")


func use(_user: Node3D):
	_user.animator.play("swing_down")


func use2(_user: Node3D):
	_user.animator.play("swing_down")


func use_callback(_user: Node3D):
	pass


func get_pointed_block(_user: Node3D, col=3):
	var origin = _user.camera.global_position
	var hit = G.tool.raycast(origin, _user.forward, 1, col)
	return hit


func get_user_block(_user: Node3D):
	var origin = _user.get_global_transform().origin
	var hit = G.tool.raycast(origin, Vector3(0, -99, 0), 10, 8)
	return hit


func drop(_user):
	var user_pos = get_user_block(_user)
	if user_pos != null:
		var floor_item = to_prop_item()
		floor_item.position = Vector3(user_pos.previous_position) + G.V2_HALF
		G.stock.add_child(floor_item)


func to_prop_item():
	var floor_item = Item.instantiate()
	floor_item.set_item(self)
	return floor_item


func on_held(_user):
	pass


func on_unheld(_user):
	pass


func on_wear(_user):
	pass


func on_unwear(_user):
	pass


func on_held_tick(_user: Node3D):
	pass
