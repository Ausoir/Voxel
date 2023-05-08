extends Node

var action
var delay = 0
var stamina = 0
var _show_progress = true
var _binding = {}
var _animator
var _callback


func set_unit(unit):
	_animator = unit.animator


func on_process(delta):
	DDD.set_text("action", _animator.current_animation)
	if delay > 0:
		delay -= delta
		stamina = max(0, stamina - delta)
	elif action != null:
		stamina = max(0, stamina - delta)
		if _callback != null:
			_animator.play("RESET")
			_callback.call()
		_callback = null
		action = null
	else:
		stamina = min(10, stamina + delta * 2)


func set_next(new_action, new_delay, callback=null):
	if action == null and new_delay <= stamina:
		action = new_action
		var binding = _binding.get(new_action)
		if binding != null:
			binding.call()
		delay = new_delay
		_callback = callback


func bind(key, callback):
	_binding[key] = callback

 
func get_progress_percentage():
	if _show_progress and stamina < 10:
		return (10 - stamina) / 10
	else:
		return -1
