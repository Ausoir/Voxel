extends Area3D


func _on_body_entered(body):
	var hit = body.get_parent()
	hit.perceived(true)


func _on_body_exited(body):
	var hit = body.get_parent()
	hit.perceived(false)
