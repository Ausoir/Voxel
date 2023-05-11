extends Node3D

@export var _remaining_time := 1.0

@onready var _animation_player = $AnimationPlayer


func _ready():
	_animation_player.play("auto")


func _process(delta: float):
	_remaining_time -= delta
	if _remaining_time <= 0:
		queue_free()
		return
