extends "../item.gd"


const Selection = preload("./remove_selection.tscn")

var _cursor = Selection.instantiate()
var _cursor_size = Vector3(.5, .5, .5)

@onready var _blocks = get_node("/root/Game/Blocks")


func use(_user: Node3D):
	var hit = get_pointed_block(_user, 9)
	if hit != null:
		G.tool.remove_block(hit.position)
		_user.action.set_next("idle", .1)


func on_held(_user: Node3D):
	_blocks.add_child(_cursor)


func on_unheld(_user: Node3D):
	_blocks.remove_child(_cursor)


func on_held_tick(_user: Node3D):
	var hit = get_pointed_block(_user, 9)
	if hit != null:
		_cursor.position = Vector3(hit.position) + _cursor_size
