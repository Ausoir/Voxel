extends Control

var _buff
@onready var _texture = $TextureRect
@onready var _label = $Label


func set_buff(p):
	_buff = p
	update_sprite()
	update_cooldown()


func update_cooldown():
	_label.set_text(str(_buff.duration))


func update_sprite():
	_texture.set_texture(_buff.sprite)


func _on_mouse_entered():
	var dsc = _buff.get_description()
	G.ui.set_description(dsc, global_position, true)


func _on_mouse_exited():
	G.ui.set_description(null, null)
