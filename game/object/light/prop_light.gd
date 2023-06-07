extends "res://game/object/prop.gd"


@onready var _light = $Light


func _ready():
	sid = "game/blocks/lights/torch"


func perceived(p):
	_light.set_shadow(p)


func set_strength(p):
	_light.light_energy = p / 5
	if _light is OmniLight3D:
		_light.omni_range = p
	else:
		_light.spot_range = p
