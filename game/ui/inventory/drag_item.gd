extends TextureRect


var item


func _ready():
	set_process(false)


func start(item_data):
	item = item_data
	if item_data == null:
		stop()
		return
	else:
		set_texture(item_data.sprite)
	set_process(true)
	show()


func stop():
	set_process(false)
	hide()


func _process(_delta):
	var mpos = get_parent().get_local_mouse_position()
	position = mpos - size / 2.0

