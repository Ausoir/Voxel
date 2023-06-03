extends "res://game/items/prop.gd"


@onready var _light = $Light


func _ready():
	sid = "game/blocks/lights/torch"


func perceived(p):
	_light.set_shadow(p)


func set_strength(p):
	_light.light_energy = p / 5
	_light.spot_range = p
