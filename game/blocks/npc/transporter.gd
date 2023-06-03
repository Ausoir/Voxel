extends "res://game/items/prop.gd"

const MULTISELECT = preload("res://game/ui/menus/multiselect.tscn")
var callback = Callable(self, "on_activate")
var _menu


func _ready():
	sid = "game/blocks/npc/transporter"
	var pos = position.floor()
	G.tool.set_voxel(pos, 3)
	_menu = MULTISELECT.instantiate()
	for i in G.mapdata.down:
		var txt = str("Enter <",i.capitalize(),">")
		_menu.add_button(txt, on_press.bind(i))


func remove():
	var pos = position.floor()
	G.tool.set_voxel(pos, 0)
	queue_free()


func on_interact(_user: Node3D):
	_user.action.set_next("use", 0.4, callback.bind(_user))
	_user.action.show_progress = true
	_user.action.cancelable = true


func on_activate(_user: Node3D):
	G.sfx.play("door_open", position)
	G.ui.display(_menu)
	G.ui.set_message('Guildsman: "Where do you want to go?"')


func on_press(to):
	G.player.load_map(to)
