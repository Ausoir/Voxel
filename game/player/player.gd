extends Node


@onready var unit = $Unit


func _ready():
	$Interface.set_unit($Unit)
