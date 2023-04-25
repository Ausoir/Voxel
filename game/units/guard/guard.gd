extends Node3D


@onready var unit = $Unit
var approach = Callable(self, "_approach")
var task = approach
var target = Vector3(3, 3, 3)


func _physics_process(delta):
	unit.head = unit
	unit.forward = -get_transform().basis.z.normalized()
	if task != null:
		task.call()


func _approach():
	var pos = G.you.get_parent().position - position
	unit.walk_cardinal(pos.x, pos.z)
