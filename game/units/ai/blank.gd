extends Node

var in_range = false
@onready var _unit = get_parent()


func _ready():
	_unit.camera = _unit
	_unit.forward = -_unit.get_transform().basis.z.normalized()

