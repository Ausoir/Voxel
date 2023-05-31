extends "res://game/ui/menus/base.gd"


func add_button(text, callback):
	var button = Button.new()
	button.set_text(text)
	$Panel/VBox.add_child(button)
	button.connect("pressed", Callable(self, "_on_press").bind(callback))
	return button


func _on_press(callback):
	G.ui.clear()
	callback.call()
