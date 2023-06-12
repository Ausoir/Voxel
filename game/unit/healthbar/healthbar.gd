extends Node3D

const COLORS = preload("./fg_gradient.tres")
var _lifetime = 0
var _target_current: float = 0
var _unit
@onready var _bar = $SubViewport/TextureProgressBar


func _ready():
	var mat = $Billboard.get_material_override()
	mat.albedo_texture = $SubViewport.get_texture()
	$SubViewport.set_update_mode(SubViewport.UPDATE_WHEN_PARENT_VISIBLE)


func set_unit(p):
	_unit = p
	position = Vector3(0, _unit.size.y, 0)
	_unit.add_child(self)
	_unit.health_changed.connect(on_health_change)
	on_health_change()


func on_health_change():
	set_max(_unit.data.get("health", 1))


func remove():
	$Billboard.set_material_override(null)


func set_max(p: int):
	_bar.set_max(p)
	_bar.set_value(p)
	_target_current = p


func set_current(p: int):
	_bar.set_value(_target_current)
	_target_current = p
	_lifetime = max(_lifetime, 1)
	show()


func _process(delta):
	if visible:
		_lifetime -= delta
		if _lifetime <= 0:
			hide()
		else:
			var lerpval = lerp(_bar.value, _target_current, .015)
			_bar.set_value(max(0, lerpval))
			_bar.tint_progress = COLORS.sample(_bar.get_as_ratio())

