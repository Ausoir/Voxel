extends CanvasLayer

const ICON_PLAYER = preload("res://assets/ui/icon_player.png")
const ICON_SETTINGS = preload("res://assets/ui/icon_settings.png")
var last_touch_time = 0
var screen_size
var on = false
var showfps = true
var _unit
@onready var menu_button = $MenuButton
@onready var n_fps = $FPS
@onready var menu_container = $Center/Menu
@onready var label = $Center/Label
@onready var desc = $Description


func _ready():
	get_tree().get_root().connect("size_changed", Callable(self, "on_resize"))
	on_resize()
	fadein()


func set_unit(unit):
	_unit = unit
	$HotBar/ItemBar.set_unit(unit)
	$Center/Progress.set_unit(unit)
	$BuffList.set_unit(unit)
	unit.equipment.connect("selected", Callable($HotBar/ItemBar, "update_items"))
	unit.equipment.connect("changed", Callable($HotBar/ItemBar, "update_views"))


func on_resize():
	screen_size = get_viewport().get_visible_rect()
	$Fade.set_size(screen_size.size)


func set_label(txt):
	if label.text != txt:
		label.set_text(txt)


func set_description(txt, pos, right=false):
	if txt == null:
		desc.hide()
	else:
		desc.set_text(txt)
		desc.show()
		desc.position = pos
		if right:
			desc.position.x -= desc.size.x


func fadein():
	$Animation.play("fadein")


func display(p):
	if !on:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		on = true
		$HotBar.hide()
		$Center/Crosshair.hide()
		$Animation.play("tint")
		menu_container.add_child(p)
		p.set_unit(_unit)
	else:
		clear()


func clear():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	on = false
	desc.hide()
	$Animation.stop()
	$Fade.color = Color.TRANSPARENT
	$HotBar.show()
	$Center/Crosshair.show()
	for i in menu_container.get_children():
		menu_container.remove_child(i)


func _process(_delta):
	last_touch_time += _delta
	if showfps:
		n_fps.set_text(str(Engine.get_frames_per_second())+' FPS')
