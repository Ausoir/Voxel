extends "res://game/ui/menus/base.gd"

var callback


func set_text(txt):
	$Panel/RichTextLabel.set_text(txt)


func _on_button_pressed():
	G.ui.clear()
	callback.call()
