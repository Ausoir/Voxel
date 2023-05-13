extends Node


var load_blocks = {}
var load_props = []


func _on_timeout():
	for key in load_blocks.keys():
		var chunk = load_blocks[key]
		for next in chunk:
			var pos = next[0]
			var block_id = next[1]
			var view = next[2]
			G.tool.set_block(pos, block_id, view)
	for prop in load_props:
		G.stock.make_object(prop[0], prop[1])
	load_blocks.clear()
