const PROMPT = preload("res://game/ui/menus/prompt.tscn")


func tip(_p):
	var _menu = PROMPT.instantiate()
	var desc = G.stock.get_desc(str("tip_",randi_range(1, 4)))
	if desc != null:
		_menu.set_text(desc)
		G.ui.display(_menu)


func on_press(to):
	G.player.load_map(to)

