extends RichTextLabel


var _lifetime = 0

func display(txt):
	set_text(txt)
	_lifetime = 3
	show()
	set_process(true)


func _process(delta):
	_lifetime -= delta
	if _lifetime <= 0:
		hide()
		set_process(false)
