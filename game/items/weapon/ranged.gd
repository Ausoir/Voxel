extends "./weapon.gd"

const Scene = preload("./laser.tscn")


func use(_user: Node3D):
	var anim_name = "shoot"
	var animation = _user.animator.get_animation(anim_name)
	if animation != null:
		var speed = data.get("speed", 1.0)
		var anim_dur = animation.get_length() * (1 / speed)
		_user.animator.seek(0)
		_user.animator.play(anim_name, .1, speed)
		_user.action.force_set_next("use", anim_dur - .2)
		_user.action.show_progress = true


func on_held_tick(_user: Node3D):
	if _user.equipment.swinging > 0:
		_user.equipment.swinging = 0
		callback.call(_user)


func use_callback(_user: Node3D):
	var from = _user.get_item_position()
	var held_item = _user.held_item_model
	var toward = -held_item.get_global_transform().basis.z
	var item_length = -held_item.mesh.get_aabb().position.z
	var hitvoxel = G.tool.raycast(from, toward, item_length, 8)
	if hitvoxel == null:
		var rocket = Scene.instantiate()
		rocket.callback = Callable(self, "on_collide")
		rocket.position = held_item.global_position + toward * item_length
		G.stock.add_child(rocket)
		var spread = data.get("spread", 0)
		var projectile_direction = G.rng.v3_spread(spread) + _user.forward
		rocket.set_direction(projectile_direction)
		var delay = data.get("delay", 1)
		_user.action.force_set_next("idle", delay)


func on_collide(hit):
	if hit.collider.collision_layer & 4 > 0:
		var unit = hit.collider.get_parent()
		apply_damage(unit, hit.position)
	else:
		G.stock.make_debris(hit.position, 3)
	G.stock.make_particle(hit.position, "explosion")
