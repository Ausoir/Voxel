extends Control

signal pressed

@onready var _selection = $Selection
@onready var _display = $TextureRect


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			call_deferred("emit_signal", "pressed")


func _notification(what: int):
	match what:
		NOTIFICATION_MOUSE_ENTER:
			_selection.visible = true
		
		NOTIFICATION_MOUSE_EXIT:
			_selection.visible = false

		NOTIFICATION_VISIBILITY_CHANGED:
			if not is_visible_in_tree():
				_selection.visible = false


func set_selected(select):
	if select:
		_selection.show()
	else:
		_selection.hide()


func set_item(item):
	if item == null:
		_display.set_texture(null)
	else:
		_display.set_texture(item.sprite)

