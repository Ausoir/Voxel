extends "../item.gd"

const RocketScene = preload("./rocket.tscn")


func use(_user: Node3D):
	var anim_name = "swing_forward"
	var animation = _user.animator.get_animation(anim_name)
	if animation != null:
		var speed = data.get("speed", 1.0)
		var anim_dur = animation.get_length() * (1 / speed)
		_user.animator.play(anim_name, .1, speed)
		_user.action.force_set_next("use", anim_dur, callback.bind(_user))
		_user.action.show_progress = true


func use_callback(_user: Node3D):
	var rocket = RocketScene.instantiate()
	rocket.callback = Callable(self, "on_collide")
	rocket.position = _user.get_item_position()
	G.stock.add_child(rocket)
	rocket.set_direction(_user.forward)
	_user.action.set_next("idle", 1)


func on_collide(hit):
	var pos = hit.position
	G.tool.block_sphere(pos, 4.0, 0)
	G.stock.make_debris(pos, 24)
	G.stock.make_particle(pos, "explosion")
