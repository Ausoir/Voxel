extends "./projectile.gd"


func _ready():
	super()
	G.sfx.play("shoot_gun", position)


func on_effect(_pos):
	G.stock.make_debris(_pos, 3)
	G.stock.make_particle(_pos, "explosion")
	G.sfx.play("explode_short", _pos)
