extends "res://game/object/prop.gd"

var voxel_pos
var parameter


func _ready():
	sid = "game/blocks/build_site/prop_build_site"
	var mat = $Billboard.get_material_override()
	mat.albedo_texture = $SubViewport.get_texture()
	$SubViewport/Label.set_text(parameter)

