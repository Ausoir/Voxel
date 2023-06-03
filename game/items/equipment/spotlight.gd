extends "../item.gd"


func use(user: Node3D):
	user.equipment.wear(self)


func on_wear(_user):
	if !_user.has_node("Light"):
		var spread = data.get("light spread", 60)
		var light
		if spread < 180:
			light = SpotLight3D.new()
			light.spot_range = data.get("light", 5)
			light.spot_angle = spread
			light.light_energy = .5 + (light.spot_range / 10.0)
		else:
			light = OmniLight3D.new()
			light.omni_range = data.get("light", 5)
			light.light_energy = .5 + (light.omni_range / 10.0)
		if "light color" in data:
			var color = data.get("light color")
			light.set_color(Color(color[0], color[1], color[2]))
		light.position.y = _user.size.y / 2
		light.rotation.y = PI
		light.set_name("Light")
		_user.get_node("Model/Body").add_child(light)


func on_unwear(_user):
	if _user.has_node("Model/Body/Light"):
		var light = _user.get_node("Model/Body/Light")
		light.queue_free()
		var body = _user.get_node("Model/Body")
		body.remove_child(light)

