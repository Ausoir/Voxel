extends Node

var action
var show_progress = false
var cancelable = false
var turnable = true
var delay = 0
var _max_delay = 0
var _binding = {}
var _animator
var _callback
var on_tick


func set_unit(unit):
	_animator = unit.animator


func on_process(delta):
	if delay > 0:
		delay -= delta
		if delay <= 0:
			if _callback != null and _callback.is_valid():
				_callback.call()
		elif on_tick != null and on_tick.is_valid():
			on_tick.call()
	elif action != null:
		_callback = null
		on_tick = null
		action = null


func set_next(new_action, new_delay, callback=null):
	if (action == null and delay <= 0) or cancelable:
		force_set_next(new_action, new_delay, callback)
		return true
	return false


func force_set_next(new_action, new_delay, callback=null):
	action = new_action
	var binding = _binding.get(new_action)
	if binding != null:
		binding.call()
	delay = new_delay
	_max_delay = new_delay
	_callback = callback
	cancelable = false
	show_progress = false
	turnable = true


func bind(key, callback):
	_binding[key] = callback

 
func get_progress_percentage():
	if show_progress and delay > 0:
		return delay / _max_delay
	else:
		return -1
