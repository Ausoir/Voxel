extends Node

@onready var _light = $DirectionalLight3D


func _unhandled_input(event):
	# TODO Make a pause menu with options?
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_L:
				# Toggle shadows
				_light.shadow_enabled = not _light.shadow_enabled


func _notification(what: int):
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			# Save game when the user closes the window
			_save_world()


func _save_world():
#	$VoxelTerrain.save_modified_blocks()
	pass

