extends "res://game/object/prop.gd"

signal attack
signal attacked
signal wait
signal special
signal weapon
signal critical
signal death
signal kill
signal health_changed

const STEP_SOUND_HEIGHT = Vector3(0, -.1, 0)
const COLLISION_CENTER = Vector3(0, .2, 0)
const HEALTHBAR = preload("./healthbar/healthbar.tscn")

var _last_velocity_y = 0
var _box_mover = VoxelBoxMover.new()
var _aabb : AABB
var _space_state
var _space_state_params
var _flash_tween
var _healthbar
var _wait_time = 0

var motor = Vector3()
var forward
var camera
var size
var data
var faction = 2
var grounded = false
var velocity = Vector3()
var action = preload("./action.gd").new()
var procedure = preload("./procedure.gd").new()
var buffs = preload("./buffs.gd").new()
var skills = preload("./skills/skills.gd").new()
var proficiency = preload("./skills/proficiency.gd").new()
var overlay_mat = preload("./flash_red.tres").duplicate()
var pilot
var physics_process = _walk_physics_process
var alert = false
var health: int = 1
var mana: int = 0
var defense: int = 0
var essence = []
var last_hitter

var _mesh
@export var _mesh_path: NodePath
@onready var body = $Body
@onready var animator = $Animator


func _ready():
	action.set_unit(self)
	buffs.set_unit(self)
	skills.set_unit(self)
	procedure.set_unit(self)
	proficiency.set_unit(self)
	_box_mover.set_collision_mask(body.get_collision_mask())
	_box_mover.set_step_climbing_enabled(true)
	_box_mover.set_max_step_height(1)
	_mesh = get_node(_mesh_path)
	_space_state = get_viewport().get_world_3d().get_direct_space_state()
	_space_state_params = PhysicsPointQueryParameters3D.new()
	_space_state_params.set_collision_mask(body.get_collision_mask())
	_space_state_params.set_exclude([body.get_rid()])
	attack.connect(on_attack)
	forward = -get_transform().basis.z.normalized()
	var interact = data.get("interact")
	if interact != null:
		body.set_collision_layer_value(1, true)


func on_interact(_user: Node3D):
	G.run_script(data.get("interact"), null)


func get_type():
	return 0


func perceived(p):
	pilot.in_range = p
	if faction == 2:
		if p:
			G.player.enemies.append(self)
		else:
			G.player.enemies.erase(self)


func take_hit(dmg):
	if dmg > 0:
		alert = true
		dmg = max(1, dmg - defense)
		buffs.set_duration("invisibility", 0)
		buffs.set_duration("regeneration", 0)
		buffs.set_duration("sleep", 0)
	if dmg != 0 and "scout" in G.you.essence:
		G.stock.make_text(self, Vector3(0, size.y + 0.1, 0), dmg)
	health -= dmg
	show_healthbar()
	if health <= 0:
		die()
	else:
		if dmg > 0:
			emit_signal("attacked", dmg)


func show_healthbar():
	if _healthbar == null:
		_healthbar = HEALTHBAR.instantiate()
		_healthbar.set_unit(self)
	_healthbar.set_current(health)


func has_essence(p):
	return essence.has(p)


func on_damaged(_pos: Vector3, damage: int, inflict):
	action.set_next("hit", .3)
	if alert:
		var ess = 0
		if has_essence("agility"):
			ess = .25
		if G.rng.percent(get_prof("dodge")*.04 + ess):
			G.stock.make_particle(position + Vector3(0, size.y/2, 0), "dodge")
			G.sfx.play("dodge", position)
			if "scout" in G.you.essence:
				G.stock.make_text(self, Vector3(0, size.y + 0.1, 0), "DODGE")
			emit_signal("special", "dodge")
			return
	else:
		G.stock.make_particle(position + Vector3(0, size.y/2, 0), "demolish")
		G.sfx.play("critical", position)
		buffs.add("silence", 1)
		buffs.add("down", 1)
	if _mesh.material_overlay == null:
		G.stock.make_particle(position + Vector3(0, size.y/2, 0), "bleed")
		start_flash(Color.RED)
		velocity += ((position-_pos).normalized() + Vector3.UP) * 4

		take_hit(damage)
		for buff in inflict:
			buffs.add(buff[0], buff[1])
	if !buffs.has("silence") and faction != 1:
		G.tool.set_sound(position, 14)


func start_flash(color):
	set_material(overlay_mat)
	_flash_tween = get_tree().create_tween()
	overlay_mat.albedo_color = color
	_flash_tween.tween_property(overlay_mat, "albedo_color", Color.TRANSPARENT, .7)
	_flash_tween.tween_callback(end_flash)


func end_flash():
	_mesh.material_overlay = null


func set_material(p):
	_mesh.material_overlay = p


func set_mesh(new_mesh):
	_mesh.set_mesh(new_mesh)
	on_mesh_set()


func on_mesh_set():
	size = _mesh.get_aabb().size + Vector3(.2, .3, .2)
	$Body/Shape.shape.set_size(size)
	$Body/Shape.position.y = size.y / 2
	_aabb = AABB(Vector3(-.3, 0, -.3), Vector3(.6, size.y, .6))


func get_head():
	return position + Vector3(0, size.y - .1, 0)


func get_center():
	return position + Vector3(0, size.y/2, 0)


func on_kill(_victim):
	var lvl = data.get("level", 1)
	var tlvl = _victim.data.get("level", 1)
	var diff = int(round(tlvl - lvl))
	if diff < 0:
		lvl += (1 >> -diff) * .5
	else:
		lvl += (1 << diff) * .5
	data["level"] = snapped(lvl, 0.01)
	if floor(data.level) != floor(lvl):
		on_level()
	emit_signal("kill", _victim)


func on_level():
	G.stock.make_particle(position, "level")
	G.sfx.play("dodge", position)


func die():
	if animator != G.filler_animator:
		if !buffs.has("polymorph"):
			if last_hitter != null:
				last_hitter.on_kill(self)
			procedure.speedmod = 0
			procedure.turn_speed = 0
			pilot.set_physics_process(false)
			$Body.collision_layer = 1
			animator.play("die")
			animator = G.filler_animator
			action.force_set_next("idle", 999)
			health = 0
			show_healthbar()
			var itemname = G.rng.get_combo(data.get("loot"))
			if itemname != null:
				var item = G.stock.make_item(itemname)
				item.drop_at(position)
			emit_signal("death")
		else:
			health = 1
		buffs.clean(true)


func revive():
	buffs.clean(true)
	pilot.set_physics_process(true)
	procedure.speedmod = 1
	procedure.turn_speed = 0.1
	$Body.collision_layer = 4
	animator = $Animator
	animator.play("RESET")
	action.force_set_next("idle", 0)
	health = 1
	_healthbar.set_current(1)


func remove():
	if _healthbar != null:
		_healthbar.remove()
	if _flash_tween != null:
		_flash_tween.kill()
	_mesh.material_overlay = null
	buffs.remove()
	queue_free()


func on_step():
	if grounded:
		var down = position + STEP_SOUND_HEIGHT
		var block = G.tool.get_block(down)
		if block != null:
			block.on_step(down)


func on_attack():
	var damage = data.get("damage", 1)
	var damage_roll = G.rng.damage_roll(damage, get_prof("unarmed"))
	var inflict = data.get("inflict", [])
	var front = procedure.get_toward_plane()
	_space_state_params.position = position + front + COLLISION_CENTER * size.z
	var hits = _space_state.intersect_point(_space_state_params, 1)
	for hit in hits:
		var t = hit.collider.get_parent()
		t.last_hitter = self
		t.on_damaged(position, damage_roll, inflict)
		emit_signal("weapon", "unarmed", t, damage_roll)
		G.sfx.play("hit_flesh", position)


func set_fp_visibility(p):
	if p:
		show()
	else:
		hide()


func get_prof(p):
	var val = proficiency.list.get(p)
	if val != null:
		return int(min(10, val))
	return 0


func req_mana(p):
	if mana >= p:
		mana -= p
		return true
	return false


func serialize():
	var r = super()
	data["proficiency"] = proficiency.serialize()
	r["data"] = data
	r["buffs"] = buffs.serialize()
	return r


func _physics_process(delta):
	physics_process.call(delta)


func _no_physics_process(_delta):
	pass


func _walk_physics_process(delta):
	if grounded:
		var center = position + COLLISION_CENTER
		_space_state_params.position = center
		var hits = _space_state.intersect_point(_space_state_params, 3)
		for hit in hits:
			var t = hit.collider.get_parent()
			velocity += (position - t.position).normalized() * 4
			t.action.set_next("idle", .5)
			action.set_next("idle", .5)
	elif position.y < -8:
		if health > 0:
			die()
		return
	else:
		motor = Vector3.ZERO

	if motor.length_squared() > 0:
		_wait_time = 0
		rotation.y = lerp_angle(rotation.y, atan2(motor.x, motor.z), .2)
		var walk_speed = velocity.length()
		if walk_speed > 0.5 and action.delay <= 0:
			animator.play("walk", 0.3, walk_speed / 4.0)
	elif action.action == null:
		animator.play("RESET")
		_wait_time += delta
		if _wait_time > 4.0:
			_wait_time = 0
			emit_signal("wait")

	velocity.x += motor.x
	velocity.z += motor.z

	var motion = velocity * delta
	var friction = .98

	var prev_motion = motion
	motion = _box_mover.get_motion(get_global_position(), motion, _aabb, G.terrain)
	if abs(motion.y) < 0.001 and prev_motion.y < -0.001:
		friction = max(0, .92 + prev_motion.y * 5)
		if !grounded:
			_last_velocity_y = 0
			G.sfx.play("land", position)
			if !has_essence("silence"):
				G.tool.set_sound(position, 6)
		grounded = true
	if abs(motion.y) > 0.001:
		grounded = false
		_last_velocity_y = prev_motion.y
	if _box_mover.has_stepped_up():
		motion = Vector3(0, min(.09, motion.y), 0)
	global_translate(motion)

	velocity.x *= friction
	velocity.z *= friction
	velocity.y = motion.y / delta - G.GRAVITY * delta


func _fly_physics_process(delta):
	grounded = true
	if motor.length_squared() > 0:
		_wait_time = 0
		rotation.y = lerp_angle(rotation.y, atan2(motor.x, motor.z), .2)
		var walk_speed = velocity.length()
		if walk_speed > 0.5 and action.delay <= 0:
			animator.play("fly", 1.0, walk_speed / 4.0)
		velocity.y += forward.y * walk_speed * .02
	elif action.action == null:
		animator.play("RESET")
		_wait_time += delta
		if _wait_time > 4.0:
			emit_signal("wait")

	velocity.x += motor.x
	velocity.z += motor.z

	var motion = velocity * delta * 0.2
	var friction = .99

	motion = _box_mover.get_motion(get_global_position(), motion, _aabb, G.terrain)
	global_translate(motion)

	velocity.x *= friction
	velocity.z *= friction
	velocity.y *= friction

