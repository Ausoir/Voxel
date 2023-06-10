extends Node

const BGM_fields = preload("res://assets/bgm/dungeon1.mp3")
const BGM_dungeons = preload("res://assets/bgm/dungeon1.mp3")
const BGM_dark = preload("res://assets/bgm/dark.wav")
var current = -1
var nodes
var size
var open
var _audio_registry = []
var _cache = {}


func _ready():
	nodes = []
	open = []
	for i in range(16):
		open.append(i)
		var node = get_node(str(i))
		nodes.append(node)
		node.connect("finished", on_sfx_finished.bind(i))


func add_audio_node(p):
	_audio_registry.append(p)


func on_music_volume_change(value):
	$Bgm.set_volume_db(value)


func on_ambient_volume_change(value):
	var db = value - 50
	for i in range(_audio_registry.size()-1, -1, -1):
		var audio = _audio_registry[i]
		if is_instance_valid(audio):
			audio.set_volume_db(db)
		else:
			_audio_registry.pop_at(i)


func on_sound_volume_change(value):
	var db = value - 50
	for player in nodes:
		player.set_volume_db(db)


func get_sound(filename):
	var sound = _cache.get(filename)
	if sound == null:
		sound = load(str("res://assets/sfx/", filename, ".wav"))
		_cache[filename] = sound
	return sound


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


func on_sfx_finished(p):
	open.append(p)


func play_bgm(p, seek=0):
	var bgm = get("BGM_"+p.replace(" ", "_"))
	if bgm != null:
		$Bgm.stream = bgm
		$Bgm.play(seek)
