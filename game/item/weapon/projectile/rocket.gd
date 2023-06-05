extends "./projectile.gd"


func _ready():
	super()
	G.sfx.play("shoot_laser", position)
