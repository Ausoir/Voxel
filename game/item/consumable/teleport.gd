extends "./consumable.gd"


func use_callback(_user: Node3D):
	G.player.load_map(data.get("to", "town"))
	super(_user)

