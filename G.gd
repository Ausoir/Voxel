extends Node

signal post_ready

const GRAVITY = 40.0
const HORIZONTAL_PLANE = Plane(Vector3.UP, 0)

var rng = preload("res://tools/rng.gd").new()
@onready var terrain = get_node("/root/Game/Terrain")
@onready var tool = get_node("/root/Game/Tool")
@onready var stock = get_node("/root/Game/Stock")
@onready var objects = get_node("/root/Game/Objects")
@onready var blocks = get_node("/root/Game/Blocks")
@onready var you = get_node("/root/Game/Player/Unit")
@onready var ui = get_node("/root/Game/Player/Interface")
@onready var save = get_node("/root/Game/Player/Save")


func _ready():
	emit_signal("post_ready")
