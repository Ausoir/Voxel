extends Node

signal post_ready

const GRAVITY = 40.0
const HORIZONTAL_PLANE = Plane(Vector3.UP, 0)
const V_HALF = Vector3(.5, .5, .5)
const V2_HALF = Vector3(.5, 0, .5)

var rng = preload("res://tools/rng.gd").new()
var frame = 0
@onready var terrain = get_node("/root/Game/Terrain")
@onready var tool = get_node("/root/Game/Tool")
@onready var stock = get_node("/root/Game/Stock")
@onready var blocks = get_node("/root/Game/Blocks")
@onready var you = get_node("/root/Game/Player/Unit")
@onready var faction = get_node("/root/Game/Player/Faction")
@onready var ui = get_node("/root/Game/Player/Interface")
@onready var save = get_node("/root/Game/Player/Save")
@onready var turn = get_node("/root/Game/Turn")


func _ready():
	emit_signal("post_ready")


func _process(_delta):
	frame += 1
