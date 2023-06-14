extends Control

signal pressed

var item


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			call_deferred("emit_signal", "pressed")


func _notification(what: int):
	match what:
		NOTIFICATION_MOUSE_ENTER:
			get_node("Selection").visible = true
		
		NOTIFICATION_MOUSE_EXIT:
			get_node("Selection").visible = false

		NOTIFICATION_VISIBILITY_CHANGED:
			if not is_visible_in_tree():
				get_node("Selection").visible = false


func set_background(bg):
	$BG.set_texture(bg)


func set_selected(select):
	if select:
		get_node("Selection").show()
	else:
		get_node("Selection").hide()


func set_item(p, fallback=null):
	item = p
	if p == null:
		get_node("TextureRect").set_texture(fallback)
	else:
		get_node("TextureRect").set_texture(item.sprite)

