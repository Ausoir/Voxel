extends "../item.gd"


func use(_user: Node3D):
	var anim_name = "eat"
	var animation = _user.animator.get_animation(anim_name)
	if animation != null:
		var speed = data.get("speed", 1.0)
		var anim_dur = animation.get_length() * (1 / speed)
		_user.animator.seek(0, true)
		_user.animator.play(anim_name, .1, speed)
		_user.action.force_set_next("use", anim_dur, use_callback.bind(_user))
		_user.action.show_progress = true
		_user.action.cancelable = true


func use_callback(_user: Node3D):
	for buff in data.get("buffs", []):
		_user.buffs.add(buff[0], buff[1])

