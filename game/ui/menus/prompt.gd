extends "res://game/ui/menus/base.gd"


func set_text(txt):
	$Panel/RichTextLabel.set_text(txt)


func hide_return():
	$Panel/VBox/Button.hide()


func add_button(text, callback):
	var button = Button.new()
	button.set_text(text)
	$Panel/VBox.add_child(button)
	button.pressed.connect(_on_press.bind(callback))


func _on_press(callback):
	callback.call()


func _on_return_pressed():
	G.ui.clear()
