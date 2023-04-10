extends CanvasLayer

const ICON_PLAYER = preload("res://assets/images/icon_player.png")
const ICON_SETTINGS = preload("res://assets/images/icon_settings.png")
var last_touch_time = 0
var screen_size
var on = false
@onready var menu_settings = $Menu/Settings
@onready var menu_inventory = $Menu/Inventory
@onready var menu_button = $MenuButton
@onready var n_fps = $FPS


func _ready():
	get_tree().get_root().connect("size_changed", Callable(self, "on_resize"))
	on_resize()
	fadein()


func set_unit(unit):
	menu_inventory.set_unit(unit)
	$HotBar/ItemBar.set_unit(unit)
	$Center/Progress.set_unit(unit)


func on_resize():
	screen_size = get_viewport().get_visible_rect()
	$Fade.set_size(screen_size.size)


func fadein():
	$Animation.play("fadein")


func display(p):
	if !on:
		on = true
		$HotBar.hide()
		$Center.hide()
		$Animation.play("tint")
		menu_button.show()
		if p == 0:
			menu_settings.display()
			menu_button.set_texture_normal(ICON_PLAYER)
		elif p == 1:
			menu_inventory.show()
			menu_button.set_texture_normal(ICON_SETTINGS)
	else:
		clear()


func clear():
	on = false
	$Animation.stop()
	$Fade.color = Color.TRANSPARENT
	$HotBar.show()
	$Center.show()
	menu_button.hide()
	menu_settings.hide()
	menu_inventory.hide()


func _process(_delta):
	last_touch_time += _delta
	if G.settings.showfps:
		n_fps.set_text(str(Engine.get_frames_per_second())+' FPS')


func _on_button_pressed():
	if menu_settings.visible:
		clear()
		display(1)
	elif menu_inventory.visible:
		clear()
		display(0)
