extends "../item.gd"


func use(user: Node3D):
	user.equipment.wear(self)


func on_wear(_user):
	if !_user.has_node("Light"):
		var light = SpotLight3D.new()
		light.set_name("Light")
		_user.get_node("Model/Body").add_child(light)
		light.position.y = _user.size.y / 2
		light.rotation.y = PI
		light.spot_range = data.get("light", 5)
		light.spot_angle = 60


func on_unwear(_user):
	if _user.has_node("Model/Body/Light"):
		var light = _user.get_node("Model/Body/Light")
		light.queue_free()
		var body = _user.get_node("Model/Body")
		body.remove_child(light)

