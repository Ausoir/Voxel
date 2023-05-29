extends Node

signal post_ready

const COLLISION_DESCRIPTION = ["interact", "sight", "unit", "projectile"]
const GRAVITY = 40.0
const HORIZONTAL_PLANE = Plane(Vector3.UP, 0)
const V_HALF = Vector3(.5, .5, .5)
const V2_HALF = Vector3(.5, 0, .5)

var rng = preload("res://game/rng.gd").new()
var player
var you
var noisemap
@onready var terrain = get_node("/root/Game/Terrain")
@onready var late_loader = get_node("/root/Game/Terrain/LateLoader")
@onready var tool = get_node("/root/Game/Tool")
@onready var stock = get_node("/root/Game/Stock")
@onready var blocks = get_node("/root/Game/Blocks")
@onready var ui = get_node("/root/Game/Player/Interface")
@onready var save = get_node("/root/Game/Player/Save")
@onready var turn = get_node("/root/Game/Turn")
@onready var sfx = get_node("/root/Game/Sfx")


func _ready():
	emit_signal("post_ready")
	var noise = FastNoiseLite.new()
	noise.seed = rng.rf()
	noisemap = noise.get_image(128, 128)


func get_biome(_pos: Vector3):
	return G.noisemap.get_pixel(_pos.x, _pos.z).r
