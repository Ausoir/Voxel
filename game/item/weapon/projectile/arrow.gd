extends "./projectile.gd"


func on_effect(_pos):
	G.stock.make_debris(_pos, 2)
	G.sfx.play("hit_arrow", _pos)
