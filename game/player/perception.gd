extends Area3D

@onready var _unit = get_parent()


func _on_body_entered(body):
	var hit = body.get_parent()
	if hit != _unit:
		hit.pilot.in_range = true


func _on_body_exited(body):
	var hit = body.get_parent()
	if hit != _unit:
		hit.pilot.in_range = false
