extends Node


var load_blocks = {}
var load_props = []


func _on_timeout():
	for key in load_blocks.keys():
		var chunk = load_blocks[key]
		for next in chunk:
			var pos = next[0]
			var block_id = next[1]
			G.tool.set_block(pos, block_id, null)
	for key in load_props.keys():
		var chunk = load_props[key]
		for next in chunk:
			var pos = next[0]
			var objectname = next[1]
			G.stock.make_object(pos, objectname)
	load_blocks.clear()
	load_props.clear()
