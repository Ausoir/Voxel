extends Control

const Slow = preload("res://assets/images/ui/st_slow.png")

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
	var sprite = get(_buff.name.capitalize())
	_texture.set_texture(sprite)
