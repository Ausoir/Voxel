extends "res://game/items/prop.gd"

signal pressed

const HEALTHBAR = preload("./healthbar/healthbar.tscn")

var _last_velocity_y = 0
var _box_mover = VoxelBoxMover.new()
var _aabb : AABB
var _space_state
var _space_state_params
var _flash_tween
var _healthbar

var sid = "unit"
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
var overlay_mat = preload("./flash_red.tres").duplicate()
var pilot
var health = 1

@onready var body = $Body
@onready var animator = $Animator
@onready var _terrain = get_node("/root/Game/Terrain")


func _ready():
	action.set_unit(self)
	buffs.set_unit(self)
	_box_mover.set_collision_mask(4)
	procedure.on_ready(self)
	_box_mover.set_step_climbing_enabled(true)
	_box_mover.set_max_step_height(1)
	_space_state = get_viewport().get_world_3d().get_direct_space_state()
	_space_state_params = PhysicsPointQueryParameters3D.new()
	_space_state_params.collision_mask = 16
	_space_state_params.set_exclude([$Body.get_rid()])


func perceived(p):
	pilot.in_range = p


func take_hit(dmg):
	if _healthbar == null:
		_healthbar = HEALTHBAR.instantiate()
		_healthbar.position = Vector3(0, size.y + 0.1, 0)
		add_child(_healthbar)
		_healthbar.set_max(data.get("health", 1))
	G.stock.make_text(self, Vector3(0, size.y + 0.1, 0), dmg)
	health -= dmg
	if health <= 0:
		$Body.collision_layer = 0
		animator.play("die")
		action.force_set_next("idle", 999)
		_healthbar.set_current(0)
	else:
		_healthbar.set_current(health)


func on_damaged(_pos: Vector3):
	action.set_next("hit", .3)
	buffs.add("slow", 3)
	if $Model/Mesh.material_overlay == null:
		var pos = position + Vector3(0, size.y/2, 0)
		G.stock.make_particle(pos, "bleed")
		$Model/Mesh.material_overlay = overlay_mat
		_flash_tween = get_tree().create_tween()
		overlay_mat.albedo_color = Color(.8, 0, 0, 1)
		_flash_tween.tween_property(overlay_mat, "albedo_color", Color.TRANSPARENT, .5)
		_flash_tween.tween_callback(Callable(self, "end_flash"))
		velocity += ((position-_pos).normalized() + Vector3.UP) * 4


func end_flash():
	$Model/Mesh.material_overlay = null


func set_mesh(new_mesh):
	$Model/Mesh.set_mesh(new_mesh)
	on_mesh_set()


func get_mesh():
	return $Model/Mesh


func on_mesh_set():
	size = $Model/Mesh.get_aabb().size + Vector3(.2, .3, .2)
	$Body/Shape.shape.set_size(size)
	$Body/Shape.position.y = size.y / 2
	_aabb = AABB(Vector3(-.3, 0, -.3), Vector3(.6, size.y, .6))


func get_head():
	return position + Vector3(0, size.y - .1, 0)


func remove():
	if _healthbar != null:
		_healthbar.remove()
	if _flash_tween != null:
		_flash_tween.stop()
	buffs.remove()
	queue_free()


func _physics_process(delta):
	if grounded:
		var center = position + Vector3(0, .2, 0)
		_space_state_params.position = center
		var hits = _space_state.intersect_point(_space_state_params, 1)
		for hit in hits:
			var t = hit.collider.get_parent()
			velocity += (position - t.position).normalized() * 4
			t.action.set_next("idle", .5)
			action.set_next("idle", .5)
			motor = Vector3.ZERO

	if motor.length_squared() > 0:
		rotation.y = lerp_angle(rotation.y, atan2(motor.x, motor.z), .2)
		var walk_speed = velocity.length()
		if walk_speed > 1 and action.delay <= 0:
			animator.play("walk", 1.0, walk_speed / 4.0)
	elif action.action == null:
		animator.play("RESET")

	velocity.x += motor.x
	velocity.z += motor.z

	var motion = velocity * delta
	var friction = .98

	var prev_motion = motion
	motion = _box_mover.get_motion(get_global_position(), motion, _aabb, _terrain)
	if abs(motion.y) < 0.001 and prev_motion.y < -0.001:
		grounded = true
		friction = max(0, .92 + prev_motion.y * 5)
		if _last_velocity_y < -.25:
			_last_velocity_y = 0
	if abs(motion.y) > 0.001:
		grounded = false
		_last_velocity_y = prev_motion.y
	if _box_mover.has_stepped_up():
		motion = Vector3(0, min(.17, motion.y), 0)
	global_translate(motion)

	velocity.x *= friction
	velocity.z *= friction
	velocity.y = motion.y / delta - G.GRAVITY * delta
