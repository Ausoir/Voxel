extends Node


var load_props = {}


func _on_timeout():
	for key in load_props.keys():
		var chunk = load_props[key]
		for next in chunk:
			var pos = next[0]
			var block_id = next[1]
			var view = next[2]
			G.tool.set_block(pos, block_id, view)
	load_props.clear()
