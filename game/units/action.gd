extends Node

var action
var delay = 0
var _show_progress = false
var _binding = {}
var _animator
var _callback


func set_unit(unit):
	_animator = unit.animator


func on_process(delta):
	if delay > 0:
		delay -= delta
	elif action != null:
		if _callback != null:
			_callback.call()
		_callback = null
		action = null


func set_next(new_action, new_delay, callback=null):
	if action == null and delay <= 0:
		force_set_next(new_action, new_delay, callback)
		return true
	return false


func force_set_next(new_action, new_delay, callback=null):
	action = new_action
	var binding = _binding.get(new_action)
	if binding != null:
		binding.call()
	delay = new_delay
	_callback = callback


func bind(key, callback):
	_binding[key] = callback

 
func get_progress_percentage():
	if _show_progress and delay > 0:
		return delay / 10
	else:
		return -1
