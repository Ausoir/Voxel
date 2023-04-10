extends TextureProgressBar


var _action


func set_unit(unit):
	_action = unit.action


func _process(_delta):
	var percentage = _action.get_progress_percentage()
	if percentage == -1:
		hide()
	else:
		show()
		set_value(percentage * 100.0)
