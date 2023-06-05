extends "./projectile.gd"


func _ready():
	super()
	G.sfx.play("shoot_bow", position)


func on_effect(_pos):
	G.stock.make_debris(_pos, 2)
	G.sfx.play("hit_arrow", _pos)
