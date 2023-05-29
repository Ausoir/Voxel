extends "../item.gd"


const Selection = preload("./remove_selection.tscn")

var _cursor = Selection.instantiate()
var _cursor_size = Vector3(.5, .5, .5)


func use(_user: Node3D):
	var hit = get_pointed_block(_user, 13)
	if hit != null:
		G.tool.remove_block(hit.position)
		_user.action.set_next("idle", .1)


func on_held(_user: Node3D):
	G.stock.add_child(_cursor)
	_cursor.hide()


func on_unheld(_user: Node3D):
	G.stock.remove_child(_cursor)


func on_held_tick(_user: Node3D):
	var hit = get_pointed_block(_user, 13)
	if hit != null:
		_cursor.show()
		_cursor.position = Vector3(hit.position) + _cursor_size
	else:
		_cursor.hide()
