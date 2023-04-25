extends "../item.gd"

const SELECTION = preload("./preview.tscn")
const MULTISELECT = preload("res://game/ui/menus/multiselect.tscn")

var _cursor = SELECTION.instantiate()
var _cursor_size = Vector3(.5, 0, .5)
var _chosen_id = 9

@onready var _blocks = get_node("/root/Game/Blocks")


func use(_user: Node3D):
	var hit = get_pointed_block(_user)
	if hit != null:
		var pos = hit.previous_position
		if G.tool.collide_prop_by_shape(pos, .7, 2).size() == 0:
			G.tool.place_block(pos, _chosen_id, _user.forward)
			print("Place voxel at ", pos)
		else:
			print("Can't place here!")
		_user.action.set_next("idle", .1)
	else:
		DDD.set_text("Pointed voxel", "---")


func use2(_user: Node3D):
	var multiselect = MULTISELECT.instantiate()
	for i in _blocks._blocks:
		multiselect.add_button(i.sid.capitalize(), Callable(self, "_choose_block").bind(i.sid))
	G.ui.display(multiselect)


func _choose_block(blockname):
	var block = _blocks.get_block_by_name(blockname)
	_chosen_id = block.id


func on_held(_user: Node3D):
	_blocks.add_child(_cursor)


func on_unheld(_user: Node3D):
	_blocks.remove_child(_cursor)


func on_held_tick(_user: Node3D):
	var hit = get_pointed_block(_user)
	if hit != null:
		_cursor.position = Vector3(hit.previous_position) + _cursor_size

