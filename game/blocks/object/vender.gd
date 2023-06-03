extends Node3D

const MULTISELECT = preload("res://game/ui/menus/multiselect.tscn")
const MENUS = ["Vend Water", "Vend Food"]


func _ready():
	var pos = position.floor()
	G.tool.set_voxel(pos, 3)
	G.tool.set_voxel(pos + Vector3.UP, 3)
	var meta = "Use Vending Machine"
	G.tool.get_tool().set_voxel_metadata(pos, meta)
	G.tool.get_tool().set_voxel_metadata(pos + Vector3.UP, meta)


func remove():
	var pos = position.floor()
	G.tool.set_voxel(pos, 0)
	G.tool.set_voxel(pos + Vector3.UP, 0)
	G.tool.get_tool().set_voxel_metadata(pos, null)
	G.tool.get_tool().set_voxel_metadata(pos + Vector3.UP, null)
	queue_free()


func on_interact(_user: Node3D):
	var multiselect = MULTISELECT.instantiate()
	for i in MENUS:
		multiselect.add_button(i.capitalize(), Callable(self, "_menu_select").bind(i))
	G.ui.display(multiselect)


func _menu_select(selected):
	print(selected)
