extends "res://game/units/unit.gd"

const Hand = preload("../../items/hand.gd")

var _weapon_callback
var _previous_held
var headmesh
var hand

@onready var held_item_model = $Model/Item
@onready var equipment = $Equipment


func _ready():
	super()
	equipment.set_unit(self)
	equipment.connect("selected", Callable(self, "_on_held_select"))
	hand = Hand.new()


func on_damaged(_pos: Vector3):
	if $Model/Body/Mesh.material_overlay == null:
		G.stock.make_particle(position + Vector3(0, size.y/2, 0), "bleed")
		$Model/Body/Mesh.material_overlay = overlay_mat
		$Model/Body/Head.material_overlay = overlay_mat
		var tween = get_tree().create_tween()
		overlay_mat.albedo_color = Color(1, 0, 0, 1)
		tween.tween_property(overlay_mat, "albedo_color", Color.TRANSPARENT, 1)
		tween.tween_callback(end_flash)
		velocity += ((position-_pos).normalized() + Vector3.UP) * 4


func end_flash():
	$Model/Body/Mesh.material_overlay = null
	$Model/Body/Head.material_overlay = null


func on_mesh_set():
	var head_height = $Model/Body/Head.get_aabb().size.y
	size = $Model/Body/Mesh.get_aabb().size + Vector3(0, head_height + .3, 0)
	$Body/Shape.shape.set_size(size)
	$Body/Shape.position.y = size.y / 2
	_aabb = AABB(Vector3(-.3, 0, -.3), Vector3(.6, size.y, .6))


func set_head_mesh(new_mesh):
	$Model/Body/Head.set_mesh(new_mesh)
	on_mesh_set()


func set_mesh(new_mesh):
	$Model/Body/Mesh.set_mesh(new_mesh)
	on_mesh_set()


func get_mesh():
	return $Model/Body/Mesh


func _physics_process(_delta):
	super(_delta)
	if _weapon_callback != null:
		_weapon_callback.call(self)


func get_item_position():
	return held_item_model.global_position


func _on_held_select():
	var item = equipment.get_item_by_index(equipment.get_held_index())
	if item != _previous_held:
		if _previous_held != null:
			_previous_held.on_unheld(self)
		_previous_held = item
		if item != null:
			item.on_held(self)
	if item == null:
		held_item_model.hide()
		_weapon_callback = Callable(hand, "on_held_tick")
	else:
		held_item_model.show()
		held_item_model.set_mesh(item.model)
		_weapon_callback = Callable(item, "on_held_tick")


func remove():
	super()
	equipment.remove()
