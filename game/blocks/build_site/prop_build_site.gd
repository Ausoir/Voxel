extends "res://game/items/prop.gd"

var voxel_pos
var parameter


func _ready():
	save_name = "game/blocks/build_site/prop_build_site"
	var mat = $Billboard.get_surface_override_material(0)
	mat.albedo_texture = $SubViewport.get_texture()
	$SubViewport/Label.set_text(parameter)

