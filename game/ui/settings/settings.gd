extends "res://game/ui/menus/base.gd"

signal changed
signal close


func on_display():
	$Panel/VBox/Fullscreen.button_pressed = G.settings.get("fullscreen", false)
	$Panel/VBox/FPS.button_pressed = G.settings.get("fps", false)
	$Panel/VBox/MusicSlider.value = G.settings.get("music", 50)
	$Panel/VBox/AmbientSlider.value = G.settings.get("ambient", 50)
	$Panel/VBox/SoundSlider.value = G.settings.get("sound", 50)


func on_close():
	_on_unview_controls_pressed()


func _on_return_pressed():
	emit_signal("close")


func _on_fps_toggled(button_pressed):
	G.settings.fps = $Panel/VBox/FPS.button_pressed
	emit_signal("changed", "fps")


func _on_fullscreen_toggled(button_pressed):
	G.settings.fullscreen = button_pressed
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	emit_signal("changed", "fullscreen")


func _on_music_changed(_changed):
	var v = $Panel/VBox/MusicSlider.value
	G.settings.music = v
	G.sfx.on_music_volume_change(v)
	emit_signal("changed", "music")


func _on_ambient_changed(_changed):
	var v = $Panel/VBox/AmbientSlider.value
	G.settings.ambient = v
	G.sfx.on_ambient_volume_change(v)
	emit_signal("changed", "ambient")


func _on_sound_changed(_changed):
	var v = $Panel/VBox/SoundSlider.value
	G.settings.sound = v
	G.sfx.on_sound_volume_change(v)
	emit_signal("changed", "sound")


func _on_controls_pressed():
	$Panel/ControlsText.show()
	$Panel/VBox.hide()


func _on_unview_controls_pressed():
	$Panel/ControlsText.hide()
	$Panel/VBox.show()


func _on_exit_pressed():
	if !("map" in G.vars) or G.vars.map == "camp":
		get_tree().quit()
	else:
		$Panel/QuitText.show()
		$Panel/VBox.hide()


func _on_unview_warning_pressed():
	$Panel/QuitText.hide()
	$Panel/VBox.show()


func _on_exit_anyways():
	get_tree().quit()

