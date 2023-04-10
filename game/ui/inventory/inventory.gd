extends Control

var _inv
var _unit
@onready var _equipbar = $Panel/VBox/EquipBar
@onready var _itembar = $Panel/VBox/ItemBar
@onready var _dragged_item = $Dragging

# TODO Is it worth having the hotbar in the first indexes instead of the last ones?
var _previous_mouse_mode := 0


func set_unit(unit):
	_unit = unit
	_inv = unit.equipment
	_equipbar.set_unit(unit)
	_itembar.set_unit(unit)
	_itembar.show_selection = false
	update_views()


func update_views():
	var slot_idx := 0
	for container in [_equipbar, _itembar]:
		for slot in container.get_children():
			slot.connect("pressed", Callable(self, "_on_slot_pressed").bind(slot_idx))
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
		if slot_item == null:
			# Move
			_inv.set_item_by_index(idx, _dragged_item.item)
			_dragged_item.stop()
		else:
			_inv.set_item_by_index(idx, _dragged_item.item)
			_dragged_item.start(slot_item)


func _on_dragging_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if !_dragged_item.visible:
				visible = false
			else:
				_dragged_item.item.drop(_unit)
				_dragged_item.stop()

