extends "res://game/object/prop.gd"

const PROMPT = preload("res://game/ui/menus/prompt.tscn")


func _ready():
	toughness = 999
	sid = "game/blocks/npc/mystic"
	var pos = position.floor()
	G.tool.set_voxel(pos, 3)
	call_deferred("turn_air")


func remove():
	var pos = position.floor()
	G.tool.set_voxel(pos, 0)
	queue_free()


func on_interact(_user: Node3D):
	_user.action.set_next("use", 0.4, on_activate.bind(_user))
	_user.action.show_progress = true
	_user.action.cancelable = true


func on_activate(_user: Node3D):
	var _menu = PROMPT.instantiate()
	var ess = G.you.equipment.take_essence_in_inventory()
	if ess.size() > 0:
		_menu.set_text("You have essence for me!\nSell me all your essence in your inventory and I will pay you 50 gold for each!")
		_menu.add_button("Deal!", on_deal)
	else:
		_menu.set_text("Bring me essence and I will pay 50 gold for each!")
	G.ui.display(_menu)


func on_deal():
	var ess = G.you.equipment.take_essence_in_inventory(true)
	var total = 0
	for _i in ess:
		total += 50
	G.vars.gold += total
	G.ui.msg(str("You sold ",ess.size()," essence for ",total," gold!"))
	G.sfx.play("buy", G.you.position)
	G.ui.clear()

