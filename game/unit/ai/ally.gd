extends "./sentient.gd"


func _ready():
	super()
	set_follow(G.you)


func set_default_target():
	if _target == null or _target.health <= 0:
		var center = _unit.get_center()
		var closest
		var closest_dist = 999999
		for enemy in G.player.enemies:
			var dist = enemy.position.distance_squared_to(_unit.position)
			if dist < closest_dist:
				var e = enemy.get_center()
				var dir = center.direction_to(e)
				var raycast = G.tool.raycast(center, dir, sqrt(dist), 4)
				if raycast == null:
					closest = enemy
					closest_dist = dist
		_target = closest


func perceive():
	return true

