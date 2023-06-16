extends "res://game/object/prop.gd"

const INTERFACE = preload("res://game/ui/menus/shop.tscn")


func _ready():
	sid = "game/blocks/npc/shop"
	toughness = 999
	var pos = position.floor()
	G.tool.set_voxel(pos, 3)


func remove():
	var pos = position.floor()
	G.tool.set_voxel(pos, 0)
	queue_free()


func on_interact(_user: Node3D):
	_user.action.set_next("use", 0.4, on_activate.bind(_user))
	_user.action.show_progress = true
	_user.action.cancelable = true


func on_activate(_user: Node3D):
	var _menu = INTERFACE.instantiate()
	_menu.on_set = on_set
	G.ui.display(_menu)
	G.ui.msg('Shopkeep: "Come check out my random assortment of items straight from the dumpster!"')


func on_set(idx):
	var bit = 1 << idx
	G.vars.shop += bit
