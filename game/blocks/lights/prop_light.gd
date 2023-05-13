extends "res://game/items/prop.gd"


func _ready():
	save_name = "game/blocks/lights/light"


func set_strength(p):
	$OmniLight3D.light_energy = p / 5
	$OmniLight3D.omni_range = p
