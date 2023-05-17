extends "res://game/items/prop.gd"

signal pressed


var _last_velocity_y = 0
var _box_mover = VoxelBoxMover.new()
var _aabb : AABB
var _last_pos = Vector3()

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

@onready var body = $Body
@onready var animator = $Animator
@onready var _terrain = get_node("/root/Game/Terrain")


func _ready():
	action.set_unit(self)
	buffs.set_unit(self)
	_box_mover.set_collision_mask(20)
	procedure.on_ready(self)
	_box_mover.set_step_climbing_enabled(true)
	_box_mover.set_max_step_height(1)


func perceived(p):
	pilot.in_range = p


func on_damaged(_pos: Vector3):
	action.set_next("hit", .3)
	buffs.add("slow", 3)
	if $Model/Mesh.material_overlay == null:
		G.stock.make_particle(position + size.y/2, "bleed")
		$Model/Mesh.material_overlay = overlay_mat
		var tween = get_tree().create_tween()
		overlay_mat.albedo_color = Color(.8, 0, 0, 1)
		tween.tween_property(overlay_mat, "albedo_color", Color.TRANSPARENT, .5)
		tween.tween_callback(end_flash)
		velocity += ((position-_pos).normalized() + Vector3.UP) * 4


func end_flash():
	$Model/Mesh.material_overlay = null


func set_mesh(new_mesh):
	$Model/Mesh.set_mesh(new_mesh)
	on_mesh_set()


func get_mesh():
	return $Model/Mesh


func on_mesh_set():
	size = $Model/Mesh.get_aabb().size + Vector3(0, .3, 0)
	$Body/Shape.shape.set_size(size)
	$Body/Shape.position.y = size.y / 2
	_aabb = AABB(Vector3(-.3, 0, -.3), Vector3(.6, size.y, .6))


func get_head():
	return position + Vector3(0, size.y - .1, 0)


func remove():
	if _last_pos != null:
		G.tool.set_voxel(_last_pos, 0)
	buffs.remove()
	queue_free()


func _physics_process(delta):
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
		motion.y = min(.17, motion.y)
	global_translate(motion)
	
	if grounded:
		var pos = position.floor()
		if _last_pos != pos:
			var voxel = G.tool.get_voxel(pos)
			if voxel == 0:
				if G.tool.get_voxel(_last_pos) == 1:
					G.tool.set_voxel(_last_pos, 0)
				G.tool.set_voxel(pos, 1)
				_last_pos = pos

	velocity.x *= friction
	velocity.z *= friction
	velocity.y = motion.y / delta - G.GRAVITY * delta
