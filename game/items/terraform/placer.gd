extends "../item.gd"

const SELECTION = preload("./preview.tscn")
const MULTISELECT = preload("res://game/ui/menus/multiselect.tscn")

var _cursor = SELECTION.instantiate()
var _chosen_buildable

@onready var _blocks = get_node("/root/Game/Blocks")


func use(_user: Node3D):
	_set_default_block()
	var hit = get_pointed_block(_user)
	if hit != null:
		var pos = hit.previous_position
		if G.tool.collide_prop_by_shape(pos, .7, 2).size() == 0:
			var block = _blocks.get_block_by_name(_chosen_buildable)
			G.tool.set_block(pos, block.id, _user.forward)
			print("Place voxel at ", pos)
		else:
			print("Can't place here!")
		_user.action.set_next("idle", .1)


func use2(_user: Node3D):
	var multiselect = MULTISELECT.instantiate()
	for i in data.get("buildables", []):
		multiselect.add_button(i.capitalize(), Callable(self, "_choose_block").bind(i))
	G.ui.display(multiselect)


func _set_default_block():
	if _chosen_buildable == null:
		var buildables = data.get("buildables", [])
		if !buildables.is_empty():
			_chosen_buildable = buildables[0]


func _choose_block(blockname):
	_chosen_buildable = blockname


func on_held(_user: Node3D):
	_blocks.add_child(_cursor)


func on_unheld(_user: Node3D):
	_blocks.remove_child(_cursor)


func on_held_tick(_user: Node3D):
	var hit = get_pointed_block(_user)
	if hit != null:
		_cursor.position = Vector3(hit.previous_position) + G.V_HALF

