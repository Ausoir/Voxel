extends "res://game/ui/menus/base.gd"

var _inv
var _unit
@onready var _equipbar = $Panel/VBox/EquipBar
@onready var _itembar = $Panel/VBox/ItemBar
@onready var _essencebar = $Panel/VBox/EssenceBar
@onready var _dragged_item = $Dragging

# TODO Is it worth having the hotbar in the first indexes instead of the last ones?
var _previous_mouse_mode := 0


func _ready():
	G.ui.get_node("Fade").connect("gui_input", Callable(self, "_on_background_gui_input"))


func on_display():
	var desc = G.you.proficiency.get_description()
	var txt = str("Level ",G.you.data.get("level",1),"  ",G.you.sid.capitalize(),"\n")
	txt += str("[color=GOLD]Gold[/color]: ",G.vars.gold,"\n")
	txt += str("[color=RED]Health[/color]: ",G.you.health,"/",G.you.data.health,"\n")
	txt += str("[color=BLUE]Mana[/color]: ",G.you.mana,"/",G.you.data.mana,"\n")
	txt += str("[color=GREEN]Speed[/color]: ",G.you.procedure.speed*10,"\n")
	txt += str("[color=DARK_SLATE_BLUE]Defense[/color]: ",G.you.defense,"\n")
	G.ui.set_sidetext(txt + desc)


func set_unit(unit):
	if _unit != unit:
		_unit = unit
		if unit.get_type() == 1:
			_inv = unit.equipment
			_equipbar.set_unit(unit)
			_essencebar.set_unit(unit)
			_itembar.set_unit(unit)
			_itembar.show_selection = false
			update_views()
			_inv.connect("selected", Callable(_equipbar, "update_items"))
			_inv.connect("selected", Callable(_itembar, "update_items"))
			_inv.connect("changed", Callable(self, "update_views"))


func update_views():
	_equipbar.update_views()
	_essencebar.update_views()
	_itembar.update_views()
	var slot_idx := 0
	for container in [_equipbar, _itembar, _essencebar]:
		for slot in container.get_children():
			if container == _essencebar:
				slot.connect("pressed", Callable(self, "_on_essence_slot_pressed").bind(slot_idx))
			else:
				slot.connect("pressed", Callable(self, "_on_slot_pressed").bind(slot_idx))
			slot.connect("mouse_entered", Callable(self, "_on_hover").bind(slot_idx, slot))
			slot.connect("mouse_exited", Callable(self, "_on_unhover").bind(slot_idx))
			slot_idx += 1


func _notification(what: int):
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if visible:
			_previous_mouse_mode = Input.get_mouse_mode()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
		elif _dragged_item != null:
			_dragged_item.stop()
			Input.set_mouse_mode(_previous_mouse_mode)


func _on_slot_pressed(idx: int):
	var slot_item = _inv.get_item_by_index(idx)
	if !_dragged_item.visible:
		if slot_item == null:
			return
		_inv.set_item_by_index(idx, null)
		_dragged_item.start(slot_item)
	else:
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

