extends "./pilot.gd"


func _ready():
	_unit.camera = _unit
	_unit.forward = -_unit.get_transform().basis.z.normalized()
	set_physics_process(false)


func _physics_process(_delta):
	pass

