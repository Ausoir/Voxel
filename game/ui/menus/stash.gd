extends "res://game/ui/menus/base.gd"

const ITEMSLOT = preload("res://game/ui/inventory/item_slot.tscn")

var _inv
var _unit
var on_set
var load_stash = []
var placeable = true
@onready var _equipbar = $Panel/VBox/EquipBar
@onready var _itembar = $Panel/VBox/ItemBar
@onready var _stash = $Panel/VBox/Stash
@onready var _dragged_item = $Dragging


func _ready():
	G.ui.get_node("Fade").connect("gui_input", Callable(self, "_on_background_gui_input"))
	for itemname in load_stash:
		var new = ITEMSLOT.instantiate()
		_stash.add_child(new)
		if itemname != null:
			new.set_item(G.stock.make_item(itemname))


func set_unit(unit):
	if _unit != unit:
		_unit = unit
		_inv = unit.equipment
		_equipbar.set_unit(unit)
		_itembar.set_unit(unit)
		update_views()
		_inv.connect("selected", Callable(_equipbar, "update_items"))
		_inv.connect("selected", Callable(_itembar, "update_items"))
		_inv.connect("changed", Callable(self, "update_views"))


func on_close():
	for container in [_equipbar, _itembar]:
		for slot in container.get_children():
			slot.pressed.disconnect(_on_slot_pressed)
			slot.mouse_entered.disconnect(_on_hover)
			slot.mouse_exited.disconnect(_on_unhover)
	for slot in _stash.get_children():
		slot.pressed.disconnect(_on_stash_pressed)
		slot.mouse_entered.disconnect(_on_hover)
		slot.mouse_exited.disconnect(_on_unhover)
	queue_free()


func update_views():
	_equipbar.update_views()
	_itembar.update_views()
	var slot_idx := 0
	for container in [_equipbar, _itembar]:
		for slot in container.get_children():
			slot.pressed.connect(_on_slot_pressed.bind(slot_idx))
			slot.mouse_entered.connect(_on_hover.bind(slot))
			slot.mouse_exited.connect(_on_unhover)
			slot_idx += 1
	slot_idx = 0
	for slot in _stash.get_children():
		slot.pressed.connect(_on_stash_pressed.bind(slot, slot_idx))
		slot.mouse_entered.connect(_on_hover.bind(slot))
		slot.mouse_exited.connect(_on_unhover)
		slot_idx += 1


func _on_stash_pressed(slot, idx):
	var slot_item = slot.item
	if !_dragged_item.visible:
		if slot_item == null:
			return
		on_set.call(idx, null)
		slot.set_item(null)
		_dragged_item.start(slot_item)
	elif placeable:
		on_set.call(idx, _dragged_item.item.sid)
		slot.set_item(_dragged_item.item)
		if slot_item == null:
			_dragged_item.stop()
		else:
			_dragged_item.start(slot_item)


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


func _on_hover(slot):
	var slot_item = slot.item
	if slot_item != null:
		var dsc = slot_item.get_description()
		var pos = slot.global_position + Vector2(slot.size.x, 0)
		G.ui.set_description(dsc, pos)


func _on_unhover():
	G.ui.set_description(null, null)


func _on_background_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if _dragged_item.visible:
				_dragged_item.item.drop(_unit)
				_dragged_item.stop()

