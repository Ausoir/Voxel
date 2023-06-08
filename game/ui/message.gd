extends RichTextLabel

@export var show_time = 3
var _lifetime = 0
var logs = []


func add(txt):
	_lifetime = show_time
	logs.append(str(txt))
	if logs.size() > 12:
		logs.pop_front()
	var r = ""
	for i in logs:
		r += "\n" + i
	set_text(r)
	show()
	set_process(true)


func display(txt):
	_lifetime = show_time
	set_text(str(txt))
	show()
	set_process(true)


func _process(delta):
	_lifetime -= delta
	if _lifetime <= 0:
		logs.append("\n")
		hide()
		set_process(false)


func _on_meta_hover_started(_meta):
	var desc = G.stock.get_desc(_meta)
	G.ui.set_description(desc, G.ui.mouse_pos)


func _on_meta_hover_ended(_meta):
	G.ui.set_description(null, null)

