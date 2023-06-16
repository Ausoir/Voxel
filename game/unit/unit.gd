extends "res://game/object/prop.gd"
const ACTION = preload("./action.gd")
const PROCEDURE = preload("./procedure.gd")
const BUFFS = preload("./buffs.gd")
const SKILLS = preload("./skills/skills.gd")
const PROFICIENCY = preload("./skills/proficiency.gd")
const OVERLAYMAT = preload("./flash_red.tres")

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
var action
var procedure
var buffs
var skills
var proficiency
var overlay_mat
var pilot
var physics_process = _walk_physics_process
var alert = false
var health: int = 1
var mana: int = 0
var defense: int = 0
var essence = []
var last_hitter
var body_rid

var _mesh
@export var _mesh_path: NodePath
@onready var body = $Body
@onready var animator = $Animator
@onready var model = $Model
@onready var equipment = $Equipment


func _ready():
	action = ACTION.new()
	procedure = PROCEDURE.new()
	buffs = BUFFS.new()
	skills = SKILLS.new()
	proficiency = PROFICIENCY.new()
	overlay_mat = OVERLAYMAT.duplicate()
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
	var interact = data.get("onuse")
	if interact != null:
		body.set_collision_layer_value(1, true)
	body_rid = body.get_rid()
	_space_state_params = PhysicsPointQueryParameters3D.new()
	_space_state_params.set_collision_mask(body.get_collision_mask())
	_space_state_params.set_exclude([body_rid])
	attack.connect(on_attack)
	weapon.connect(on_weapon)
	forward = -get_transform().basis.z.normalized()
	equipment.set_unit(self)


func on_interact(_user: Node3D):
	var t = data.get("onuse")
	if t != null:
		G.run_script(t[0], t[1])


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
		buffs.set_duration("invisible", 0)
		buffs.set_duration("sleep", 0)
		health -= dmg
		show_healthbar()
	if dmg != 0 and "scout" in G.you.essence:
		G.stock.make_text(self, Vector3(0, size.y + 0.1, 0), dmg)
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
	if alert:
		var ess = 0
		if has_essence("agility"):
			ess = .2
		if G.rng.percent(get_prof("dodge")*.05 + ess):
			G.stock.make_particle(Vector3(0, size.y/2, 0), "dodge", self)
			G.sfx.play("dodge", position)
			if "scout" in G.you.essence:
				G.stock.make_text(self, Vector3(0, size.y + 0.1, 0), "DODGE")
			emit_signal("special", "dodge", 1)
			return
		if has_essence("shield") and !buffs.has("exhaustion"):
			buffs.add("exhaustion", 14)
			G.sfx.play("dodge", position)
			G.stock.make_particle(Vector3(0, size.y/2, 0), "barrier", self)
			return
		if has_essence("holy") and req_mana(1):
			G.sfx.play("dodge", position)
			G.stock.make_particle(Vector3(0, size.y/2, 0), "barrier", self)
			return
		if buffs.has("invincible"):
			G.sfx.play("dodge", position)
			G.stock.make_particle(Vector3(0, size.y/2, 0), "barrier", self)
			return
		action.set_next("hit", .3)
	else:
		action.set_next("hit", .3)
		if last_hitter != null and last_hitter.has_essence("panic"):
			if last_hitter.mana == 0:
				last_hitter.mana += int(damage / 5)
		G.stock.make_particle(position + Vector3(0, size.y/2, 0), "demolish")
		G.sfx.play("critical", position)
		buffs.add("silence", 1)
		buffs.add("down", 1)
	if _mesh.material_overlay == null:
		G.stock.make_particle(position + Vector3(0, size.y/2, 0), "bleed")
		start_flash(Color.RED)
		velocity += ((position-_pos).normalized() + Vector3.UP) * 2

		take_hit(damage)
		buffs.add_all(inflict)
	if !buffs.has("silence") and faction != 1:
		G.tool.set_sound(position, 14)
	if damage > 0:
		var worn = equipment.equipment
		for part in worn.keys():
			var armor = worn[part]
			if armor != null:
				if G.rng.percent(armor.data.get("buffc", 0) * 0.1):
					if last_hitter != null:
						last_hitter.buffs.add_all(armor.data.get("inflict", []))
					buffs.add_all(armor.data.get("buff", []))


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


func set_last_hitter(p):
	if p != self:
		last_hitter = p


func on_kill(_victim):
	var lvl = data.get("level", 1)
	var tlvl = _victim.data.get("level", 1)
	var diff = int(round(tlvl - lvl)) + 2
	if diff > 0:
		earn_exp(diff * diff * .02)
	emit_signal("kill", _victim)


func earn_exp(experience):
	if !buffs.has("stunted"):
		var old_lvl = data["level"]
		var new_lvl = old_lvl + experience
		data["level"] = snapped(new_lvl, 0.01)
		if floor(data.level) != floor(old_lvl):
			on_level()


func on_level(celebrate=true):
	if celebrate:
		if G.you == self:
			G.ui.msg("Level Up!")
		G.stock.make_particle(position, "level")
		G.sfx.play("dodge", position)
	equipment.update_essence()


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
				if item != null:
					item.drop_at(position)
			emit_signal("death")
			var ondeath = data.get("ondeath")
			if ondeath != null:
				G.run_script(ondeath[0], ondeath[1])
		else:
			health = 1
			buffs.set_duration("polymorph", 0)


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
	equipment.remove()
	buffs.remove()
	queue_free()


func on_step():
	if grounded:
		var down = position + STEP_SOUND_HEIGHT
		var block = G.tool.get_block(down)
		if block != null:
			block.on_step(down)


func on_attack():
	var _attack_motion = data.get("attack", "tackle")
	var fn = Callable(self, _attack_motion)
	if fn.is_valid():
		fn.call()


func tackle():
	var hits = procedure.collide_front()
	if hits.is_empty():
		G.sfx.play("swing", position)
	else:
		for hit in hits:
			var unit = hit.collider.get_parent()
			unit.last_hitter = self
			var inflict = data.get("inflict", [])
			var damage = data.get("damage", 1)
			var damage_roll = G.rng.damage_roll(damage, get_prof("unarmed"))
			if !unit.alert:
				damage_roll += data.get("backstab", 0) + 2
			unit.on_damaged(position, damage_roll, inflict)
			emit_signal("weapon", "unarmed", unit, damage_roll)
			G.sfx.play("hit_flesh", position)


func shoot():
	var projname = data.get("projectile")
	var projectile = G.stock.Projectiles[projname].instantiate()
	projectile.radius = data.get("radius", 1)
	projectile.speed = data.get("power", 10)
	projectile.damage = data.get("damage", 5)
	projectile.inflict = data.get("inflict", [])
	projectile.position = get_center() + forward
	projectile.shooter = self
	G.stock.add_child(projectile)
	projectile.set_direction(forward)


func on_weapon(_type, _victim, _dmg):
	buffs.set_duration("lethality", 0)
	var dur = buffs.get_duration("venomous")
	if dur > 0:
		buffs.set_duration("venomous", dur - 1)


func set_fp_visibility(p):
	if p:
		model.show()
	else:
		model.hide()


func get_prof(p):
	var val = proficiency.list.get(p)
	if val != null:
		return int(min(10, val))
	return 0


func req_mana(p):
	if mana >= p:
		mana -= p
		if p > 0 and mana == 0:
			G.stock.make_particle(position, "spend")
			G.sfx.play("mana_spend", position)
		return true
	return false


func serialize():
	var r = super()
	data["proficiency"] = proficiency.serialize()
	data["buffs"] = buffs.serialize()
	r["data"] = data
	r.merge(equipment.serialize(), true)
	return r


func _physics_process(delta):
	physics_process.call(delta)


func _no_physics_process(_delta):
	pass


func _walk_physics_process(delta):
	if !grounded:
		if position.y < -8:
			if health > 0:
				last_hitter = null
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
		if grounded:
			var center = position + COLLISION_CENTER
			_space_state_params.position = center
			var hits = _space_state.intersect_point(_space_state_params, 2)
			for hit in hits:
				var t = hit.collider.get_parent()
				var diff = (t.position - position).normalized()
				t.velocity += diff
				velocity += -diff
	elif action.action == null:
		animator.play("RESET")
		_wait_time += delta
		if _wait_time > 4.0:
			emit_signal("wait")
			_wait_time = 0

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
		var center = position
		_space_state_params.position = center
		var hits = _space_state.intersect_point(_space_state_params, 1)
		for hit in hits:
			var t = hit.collider.get_parent()
			var diff = (t.position - position).normalized()
			velocity += -diff
			t.velocity += diff
	elif action.action == null:
		animator.play("RESET")
		_wait_time += delta
		if _wait_time > 4.0:
			emit_signal("wait")
			_wait_time = 0

	velocity.x += motor.x
	velocity.z += motor.z

	var motion = velocity * delta * 0.2
	var friction = .99

	motion = _box_mover.get_motion(get_global_position(), motion, _aabb, G.terrain)
	global_translate(motion)

	velocity.x *= friction
	velocity.z *= friction
	velocity.y *= friction

