extends Control

signal pressed

var item


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			call_deferred("emit_signal", "pressed")


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

