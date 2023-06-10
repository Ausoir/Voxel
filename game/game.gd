extends Node


func _ready():
	$Terrain.generator.post_ready()


func _notification(what: int):
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			print("close")
		NOTIFICATION_WM_SIZE_CHANGED:
			G.ui.on_resize()

