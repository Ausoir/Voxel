extends "res://game/object/prop.gd"

const INTERFACE = preload("res://game/ui/menus/stash.tscn")
var callback = Callable(self, "on_activate")
var _menu


func _ready():
	sid = "game/blocks/npc/shop"
	var pos = position.floor()
	G.tool.set_voxel(pos, 3)
	_menu = INTERFACE.instantiate()


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
	_menu.load_stash = G.vars.stash
	_menu.on_set = on_set
	G.ui.display(_menu)
	G.ui.msg('Storage Keeper: "I keep your items safe, until you die!"')


func on_set(idx, itemname):
	G.vars.stash[idx] = itemname
