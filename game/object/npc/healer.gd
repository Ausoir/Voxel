extends "res://game/object/prop.gd"

const MULTISELECT = preload("res://game/ui/menus/multiselect.tscn")
var callback = Callable(self, "on_activate")
var _menu


func _ready():
	toughness = 999
	sid = "game/blocks/npc/healer"
	var pos = position.floor()
	G.tool.set_voxel(pos, 3)
	_menu = MULTISELECT.instantiate()
	var idx := 0
	for i in ["Receive <Guardian Angel> $15", "Receive <Heal> $5", "Receive <Cure All> $10"]:
		var button = _menu.add_button(i, on_press.bind(idx))
		button.connect("mouse_entered", Callable(self, "on_hover").bind(idx, button))
		button.connect("mouse_exited", Callable(self, "on_unhover"))
		idx += 1


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
	G.ui.msg('Priest: "Come to me for a blessing, or perish forever!"')


func on_press(idx):
	if idx == 0 and _require(15):
		G.you.buffs.add("track", -1)
		G.ui.msg('Priest: "You will now be brought back alive when taken to critical health."')
	elif idx == 1 and _require(5):
		G.you.health = G.you.data.health
		G.ui.msg('Priest: "You have been mended."')
	elif idx == 2 and _require(10):
		G.you.buffs.clean()
		G.ui.msg('Priest: "You ill no more."')
	G.ui.clear()


func _require(p):
	if G.vars.gold >= p:
		G.vars.gold -= p
		return true
	G.ui.msg('Priest: "Bring more gold."')
	return false


func on_hover(idx, slot):
	var pos = slot.global_position + Vector2(slot.size.x, 0)
	if idx == 0:
		G.ui.set_description("Teleport back to camp when taken to critical health.", pos)
	elif idx == 1:
		G.ui.set_description("Heal to full health.", pos)
	elif idx == 2:
		G.ui.set_description("Removal all status effects.", pos)


func on_unhover():
	G.ui.set_description(null, null)
