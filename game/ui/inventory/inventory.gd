extends "res://game/ui/menus/base.gd"

var _inv
var _unit
@onready var _equipbar = $Panel/VBox/EquipBar
@onready var _itembar = $Panel/VBox/ItemBar
@onready var _essencebar = $Panel/VBox/EssenceBar
@onready var _dragged_item = $Dragging


func _ready():
	G.ui.get_node("Fade").gui_input.connect(_on_background_gui_input)


func on_display():
	G.ui.message.show()
	G.ui.message.can_hide = false
	var desc = G.you.proficiency.get_description()
	var lvls = G.you.data.get("level", 1)
	var lvl = floor(lvls)
	var lvl_exp = int((lvls - lvl) * 100)
	var txt = str(G.you.sid.capitalize(),"\n","Level ",lvl," [i](",lvl_exp,"%)[/i]","\n")
	txt += str("[color=GOLD]Gold[/color]: ",G.vars.gold,"\n")
	txt += str("[color=RED]Health[/color]: ",G.you.health,"/",G.you.data.health,"\n")
	txt += str("[color=BLUE]Mana[/color]: ",G.you.mana,"/",G.you.data.mana,"\n")
	txt += str("[color=GREEN]Speed[/color]: ",G.you.procedure.speed*10,"\n")
	txt += str("[color=DARK_SLATE_BLUE]Defense[/color]: ",G.you.defense,"\n")
	G.ui.set_sidetext(txt + desc)


func on_close():
	G.ui.message.can_hide = true
	G.ui.message.hide()


func set_unit(unit):
	if _unit != unit:
		if _unit != null:
			unset_unit(_unit)
		_unit = unit
		if unit.get_type() == 1:
			_inv = unit.equipment
			_equipbar.set_unit(unit)
			_essencebar.set_unit(unit)
			_itembar.set_unit(unit)
			update_views()
			_inv.selected.connect(_equipbar.update_items)
			_inv.selected.connect(_itembar.update_items)
			_inv.changed.connect(update_views)


func unset_unit(_p):
	if _p.get_type() == 1:
		_p.equipment.selected.disconnect(_equipbar.update_items)
		_p.equipment.selected.disconnect(_itembar.update_items)
		_p.equipment.changed.disconnect(update_views)


func update_views():
	_equipbar.update_views()
	_essencebar.update_views()
	_itembar.update_views()
	var slot_idx := 0
	for container in [_equipbar, _itembar, _essencebar]:
		for slot in container.get_children():
			if container == _essencebar:
				slot.pressed.connect(_on_essence_slot_pressed.bind(slot_idx))
			else:
				slot.pressed.connect(_on_slot_pressed.bind(slot_idx))
			slot.mouse_entered.connect(_on_hover.bind(slot_idx, slot))
			slot.mouse_exited.connect(_on_unhover.bind(slot_idx))
			slot_idx += 1


func _on_slot_pressed(idx: int):
	var slot_item = _inv.get_item_by_index(idx)
	if !_dragged_item.visible:
		if slot_item == null:
			return
		_inv.set_item_by_index(idx, null)
		_dragged_item.start(slot_item)
	else:
		if _unit.action.set_next("wield", 1):
			_unit.action.show_progress = true
			_unit.procedure.speedmod = 0.5
			_inv.set_item_by_index(idx, _dragged_item.item)
			if slot_item == null:
				# Move
				_dragged_item.stop()
			else:
				_dragged_item.start(slot_item)


func _on_essence_slot_pressed(idx: int):
	var slot_item = _inv.get_item_by_index(idx)
	if _dragged_item.visible and slot_item == null:
		if _inv.get_index_type(idx) == 2:
			if _inv.absorb(_dragged_item.item) == 0:
				_dragged_item.stop()


func _on_hover(idx: int, slot):
	var slot_item = _inv.get_item_by_index(idx)
	if slot_item != null:
		var dsc = slot_item.get_description()
		var pos = slot.global_position + Vector2(slot.size.x, 0)
		G.ui.set_description(dsc, pos)


func _on_unhover(_idx: int):
	G.ui.set_description(null, null)


func _on_background_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if _dragged_item.visible:
				_dragged_item.item.drop(_unit)
				_dragged_item.stop()

