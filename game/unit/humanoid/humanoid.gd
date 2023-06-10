extends "res://game/unit/unit.gd"

var _weapon_callback
var _previous_held
var headmesh
var bodymesh

@onready var held_item_model = $Model/Item
@onready var equipment = $Equipment


func _ready():
	super()
	equipment.set_unit(self)
	equipment.connect("selected", Callable(self, "_on_held_select"))
	attack.disconnect(on_attack)


func get_type():
	return 1


func on_level():
	super()
	equipment.set_unit(self)


func set_material(p):
	_mesh.material_overlay = p
	$Model/Body/Head.material_overlay = p


func end_flash():
	super()
	$Model/Body/Head.material_overlay = null


func on_mesh_set():
	var head_height = $Model/Body/Head.get_aabb().size.y
	size = $Model/Body/Mesh.get_aabb().size + Vector3(.5, head_height + .3, .5)
	$Body/Shape.shape.set_size(size)
	$Body/Shape.position.y = size.y / 2
	_aabb = AABB(Vector3(-.3, 0, -.3), Vector3(.6, size.y, .6))


func set_head_mesh(new_mesh):
	$Model/Body/Head.set_mesh(new_mesh)
	on_mesh_set()


func _physics_process(_delta):
	super(_delta)
	if _weapon_callback != null:
		_weapon_callback.call(self)


func get_item_position():
	return held_item_model.global_position


func _on_held_select():
	var item = equipment.get_held_item()
	if item != _previous_held:
		if _previous_held != null:
			_previous_held.on_unheld(self)
		else:
			procedure.hand.on_unheld(self)
		_previous_held = item
		if item != null:
			item.on_held(self)
		else:
			procedure.hand.on_held(self)
	if item == null:
		held_item_model.hide()
		_weapon_callback = Callable(procedure.hand, "on_held_tick")
	else:
		held_item_model.show()
		held_item_model.set_mesh(item.model)
		var sz = item.data.get("size", .5)
		held_item_model.set_scale(Vector3(sz, sz, sz))
		_weapon_callback = Callable(item, "on_held_tick")


func has_essence(p):
	if super(p):
		return true
	var item = equipment.get_item_by_index(equipment.get_held_index())
	if item != null and item.data.get("essence", "") == p:
		return true
	return false


func remove():
	super()
	equipment.remove()


func serialize():
	var r = super()
	r.merge(equipment.serialize(), true)
	return r


func set_fp_visibility(p):
	if p:
		$Model/Body/Mesh.show()
		$Model/Body/Head.show()
	else:
		$Model/Body/Mesh.hide()
		$Model/Body/Head.hide()
