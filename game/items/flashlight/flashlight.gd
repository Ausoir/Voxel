extends "../item.gd"

const PROP = preload("res://game/items/flashlight/flashlight.tscn")

var switch = true
var prop


func use(_user: Node3D):
	_user.animator.play("aim")
	

func use2(_user: Node3D):
	if switch:
		on_unheld(_user)
	else:
		on_held(_user)
	switch = !switch


func on_held(_user):
	prop = PROP.instantiate()
	_user.held_item_model.add_child(prop)


func on_unheld(_user):
	if prop != null:
		prop.queue_free()
