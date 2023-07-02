extends Node


func _notification(what: int):
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			G.quit()
		NOTIFICATION_WM_SIZE_CHANGED:
			G.ui.on_resize()
