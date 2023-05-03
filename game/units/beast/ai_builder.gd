extends Node

const Pathing = preload("res://game/units/ai/pathing.gd")

var _pathing = Pathing.new()
var path = Callable(self, "_path")
var task = path
@onready var _unit = get_parent()


func _ready():
	_unit.head = _unit
	_pathing.set_unit(_unit)


func _physics_process(_delta):
	_unit.forward = -_unit.get_transform().basis.z.normalized()
	if task != null:
		task.call(_delta)


func _path(_delta):
	_pathing.target = G.you.position.floor()
	_pathing.perform(_delta)
#	if _pathing.reached:

