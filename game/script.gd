const PROMPT = preload("res://game/ui/menus/prompt.tscn")


func prompt(_p):
	var _menu = PROMPT.instantiate()
	var desc = G.stock.get_desc(_p)
	if desc != null:
		_menu.set_text(desc)
		G.ui.display(_menu)


func gameover(_p):
	var _menu = PROMPT.instantiate()
	var txt = "You have cleared the Alpha!"
	txt += str("\nOn Day ", G.vars.day)
	txt += str("\nWith a Level ", floor(G.you.data.level), " ", G.vars.name.capitalize())
	if !G.you.essence.is_empty():
		txt += str("\nUsing ", ", ".join(G.you.essence))
	txt += str("\nCarrying ", G.vars.gold, " Gold")
	txt += "\n"
	txt += "\nYour proficiencies:\n"
	txt += G.you.proficiency.get_plain_description()
	var time = Time.get_datetime_string_from_system()
	G.files.save_highscore([time, txt, G.vars])
	txt += "\n"
	txt += "\nRecord of this victory is saved in your save games folder."
	txt += "\nThanks for playing!"
	_menu.set_text(txt)
	_menu.hide_return()
	_menu.add_button("Quit", G.quit)
	G.ui.display(_menu)


func bgm(_p):
	var timer = Timer.new()
	G.add_child(timer)
	timer.start(8)
	timer.timeout.connect(bgm_timeout.bind(_p, timer))
func bgm_timeout(_p, timer):
	G.sfx.play_bgm(_p)
	G.remove_child(timer)
	timer.queue_free()

