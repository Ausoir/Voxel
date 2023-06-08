extends CanvasLayer

const ICON_PLAYER = preload("res://assets/ui/icon_player.png")
const ICON_SETTINGS = preload("res://assets/ui/icon_settings.png")
var last_touch_time = 0
var screen_size
var on = false
var showfps = true
var mouse_pos = Vector2.ZERO
var _unit
@onready var menu_button = $MenuButton
@onready var n_fps = $FPS
@onready var menu_container = $Center/Menu
@onready var label = $Center/Label
@onready var desc = $Description
@onready var message = $Message
@onready var sidetext = $Sidetext
@onready var fade = $Fade
@onready var animation = $Animation


func _ready():
	get_tree().get_root().connect("size_changed", Callable(self, "on_resize"))
	on_resize()


func _input(event):
	if event is InputEventMouseMotion:
		mouse_pos = event.position


func set_unit(unit):
	_unit = unit
	$Center/Progress.set_unit(unit)
	$BuffList.set_unit(unit)
	if unit.get_type() == 1:
		$HotBar/ItemBar.show()
		$HotBar/ItemBar.set_unit(unit)
		unit.equipment.connect("selected", Callable($HotBar/ItemBar, "update_items"))
		unit.equipment.connect("changed", Callable($HotBar/ItemBar, "update_views"))
	else:
		$HotBar/ItemBar.hide()
	unit.attacked.connect(on_hit)


func unset_unit(unit):
	$BuffList.unset_unit(unit)
	if unit.get_type() == 1:
		$HotBar/ItemBar.show()
		$HotBar/ItemBar.set_unit(unit)
		unit.equipment.selected.disconnect(Callable($HotBar/ItemBar, "update_items"))
		unit.equipment.changed.disconnect(Callable($HotBar/ItemBar, "update_views"))
	unit.attacked.disconnect(on_hit)


func on_hit(_dmg):
	animation.play("red")


func on_resize():
	screen_size = get_viewport().get_visible_rect()
	fade.set_size(screen_size.size)


func set_label(txt):
	if label.text != txt:
		label.set_text(txt)


func msg(txt):
	if txt == null:
		message.add("")
	else:
		message.add(txt)


func set_sidetext(txt):
	sidetext.display(txt)


func set_description(txt, pos, right=false):
	if txt == null:
		desc.hide()
		desc.size.x = 256
		desc.size.y = 64
	else:
		desc.set_text(txt)
		desc.show()
		desc.position = pos
		if right:
			desc.position.x -= desc.size.x


func fadein():
	animation.play("fadein")


func display(p):
	if !on:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		on = true
		$HotBar.hide()
		$Center/Crosshair.hide()
		animation.play("tint")
		menu_container.add_child(p)
		p.set_unit(_unit)
		p.on_display()
	else:
		clear()


func clear():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	on = false
	desc.hide()
	animation.stop()
	sidetext.hide()
	fade.color = Color.TRANSPARENT
	$HotBar.show()
	$Center/Crosshair.show()
	for i in menu_container.get_children():
		i.on_close()
		menu_container.remove_child(i)


func _process(_delta):
	last_touch_time += _delta
	if showfps:
		var fps = Engine.get_frames_per_second()
		n_fps.set_text(str(fps)+' FPS')
	if on:
		_unit.show_healthbar()
