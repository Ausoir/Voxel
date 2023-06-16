extends "res://game/item/weapon/projectile/projectile.gd"


func on_effect(_pos):
	G.stock.make_debris(_pos, 2)
	G.sfx.play("hit_arrow", _pos)


func _physics_process(delta: float):
	super(delta)
	rotate(Vector3.RIGHT, .1)
