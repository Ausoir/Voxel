extends Node


var action
var delay = 0
var _max_delay = 0
var _show_progress = true
var _binding = {}
var _action_was_set = false


func on_process(delta):
	if !_action_was_set:
		stop()
	_action_was_set = false
	if delay > 0:
		delay -= delta
	else:
		delay = 0
		_max_delay = 0
		if action != null:
			var binding = _binding.get(action)
			action = null
			if binding != null:
				binding.call()


func set_next(new_action, new_delay, show_bar=true):
	_action_was_set = true
	if delay == 0:
		action = new_action
		delay = new_delay
		_max_delay = new_delay
		_show_progress = show_bar
		return true
	return false


func stop():
	action = null
	delay = 0
	_max_delay = 0


func bind(key, callback):
	_binding[key] = callback

 
func get_progress_percentage():
	if _show_progress and action != null and _max_delay > 0:
		return (_max_delay - delay) / _max_delay
	else:
		return -1
