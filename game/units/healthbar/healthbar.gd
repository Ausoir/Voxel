extends Node3D

const COLORS = preload("./fg_gradient.tres")
var _lifetime = 0
var _target_current: float = 0
@onready var _bar = $SubViewport/TextureProgressBar


func _ready():
	var mat = $Billboard.get_surface_override_material(0)
	mat.albedo_texture = $SubViewport.get_texture()


func remove():
	$Billboard.set_surface_override_material(0, null)


func set_max(p: int):
	_bar.set_max(p)
	_bar.set_value(p)
	_target_current = p


func set_current(p: int):
	_bar.set_value(_target_current)
	_target_current = p
	_lifetime = 1
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

