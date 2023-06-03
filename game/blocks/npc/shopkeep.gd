extends "res://game/items/prop.gd"

const INTERFACE = preload("res://game/ui/menus/shop.tscn")
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
	G.ui.display(_menu)
	G.ui.set_message('Shopkeep: "Come check out my random assortment of items straight from the dumpster!"')
