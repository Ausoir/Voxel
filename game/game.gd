extends Node


func _notification(what: int):
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			# Save game when the user closes the window
			_save_world()


func _save_world():
	pass
#	$Terrain.save_modified_blocks()
#	get_node("Player/Save").save_data()

