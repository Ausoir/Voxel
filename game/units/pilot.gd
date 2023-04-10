extends Node

const Task = preload("res://game/units/task.gd")
var host
var default = null
var move = null
var attack = null
var route = null
var task = null
var priority = 5
var frame = 0
var lifetime = 500
var alert = 0
var noise = 0
var perceive_idx = 0
var is_humanoid = false
var destructiveness = 0
var has_night_vision = false
var closest_enemy

func set_ai(args):
	if args.empty():
		default = Task.Wander.new()
	elif default == null or default.get_class() != args[0]:
		default = str_to_task(args[0]).new()
	if args.size() < 2:
		if move == null:
			move = Task.Pathing.new()
	elif move == null or move.get_class() != args[1]:
		move = str_to_task(args[1]).new()
	default.pilot = self
	move.pilot = self
	attack.pilot = self
	set_task(default)

func str_to_task(p):
	if p == "guard":
		return Task.Guard
	elif p == "wander":
		return Task.Wander
	elif p == "path":
		return Task.Pathing
	elif p == "idle":
		return Task.Idle

func on_turn():
	if host.action.delay == 0:
#		if host.team == 1:
#			perceive()
#			engage(closest_enemy)
		if task.on_turn():
			task.perform()

func set_task(p):
	p.on_set()
	task = p

func remove():
	queue_free()

func on_assign():
	pass

func unassign():
	if host != null:
		host.pilot = null
		host.possess()
		host = null
