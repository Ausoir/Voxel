extends Control

signal pressed

@onready var _selection = $Selection
var item


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


func set_background(bg):
	$BG.set_texture(bg)


func set_selected(select):
	if select:
		_selection.show()
	else:
		_selection.hide()


func set_item(p, fallback=null):
	item = p
	if p == null:
		get_node("TextureRect").set_texture(fallback)
	else:
		get_node("TextureRect").set_texture(item.sprite)

