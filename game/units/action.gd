extends Node


var action
var delay = 0
var max_delay = 0
var _binding = {}


func on_process(delta):
	if delay > 0:
		delay -= delta
	else:
		delay = 0
		max_delay = 0
		if action != null:
			_binding[action].call()
		action = null


func set_next(new_action, new_delay: float = 0):
	if delay == 0:
		action = new_action
		delay = new_delay
		max_delay = new_delay
		return true
	return false


func stop(stop_action):
	if action == stop_action:
		action = null
		delay = 0
		max_delay = 0


func bind(key, callback):
	_binding[key] = callback

 
func get_progress_percentage():
	if action != null and max_delay > 0:
		return (max_delay - delay) / max_delay
	else:
		return -1
