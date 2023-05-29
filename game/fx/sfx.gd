extends Node

var current = -1
var nodes
var size
var open
var _cache = {}


func _ready():
	nodes = []
	open = []
	size = get_child_count()
	for i in range(size):
		open.append(i)
		var node = get_node(str(i))
		nodes.append(node)
		node.connect("finished", on_finished.bind(i))


func get_sound(filename):
	var sound = _cache.get(filename)
	if sound == null:
		sound = load(str("res://assets/sfx/", filename, ".wav"))
		_cache[filename] = sound
	return sound


func adjust_sound():
	var db = G.settings.sound - 50
	for player in nodes:
		player.set_volume_db(db)


func play(sound, ppos):
	var index = _find_player()
	if index != -1:
		var player = nodes[index]
		player.position = ppos
		player.set_stream(get_sound(sound))
		player.play(0)


func _find_player():
	if open.is_empty():
		return -1
#		current += 1
#		if current >= size:
#			current = 0
#		return current
	return open.pop_front()


func on_finished(p):
	open.append(p)
