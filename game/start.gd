extends Node

var stock = preload("res://game/stock.gd").new()
var desc = preload("res://assets/json/dialog.json").get_data()
var head1 = preload("res://assets/head/head1.obj")
var head2 = preload("res://assets/head/head2.obj")
var head3 = preload("res://assets/head/head3.obj")
var head4 = preload("res://assets/head/head4.obj")
var head5 = preload("res://assets/head/head5.obj")
var head6 = preload("res://assets/head/head6.obj")
var head7 = preload("res://assets/head/head7.obj")
var hcap = preload("res://assets/head/h_cap.obj")
var a_plate = preload("res://assets/body/a_plate.obj")
var a_leather = preload("res://assets/body/a_leather.obj")
var a_nomad = preload("res://assets/body/a_nomad.obj")
var a_hunter = preload("res://assets/body/a_hunter_outfit.obj")
var a_robe = preload("res://assets/body/a_white_robe.obj")
var a_grobe = preload("res://assets/body/a_green_robe.obj")
var a_yrobe = preload("res://assets/body/a_golden_robe.obj")
var a_rags = preload("res://assets/body/a_rags.obj")
var a_hide = preload("res://assets/body/a_hide.obj")
var a_suit = preload("res://assets/body/a_suit.obj")
var a_sword = preload("res://assets/weapon/katana3d.obj")
var a_staff = preload("res://assets/weapon/staff3d.obj")
var a_dagger = preload("res://assets/weapon/dagger3d-0-dagger.obj")
var a_bow = preload("res://assets/weapon/bow3d-0-bow.obj")
var a_axe = preload("res://assets/weapon/axe3d-0-axe.obj")
var a_mace = preload("res://assets/weapon/mace3d.obj")
var _character_screen = false
var _on = false
var _chosen_class

func _ready():
	Steam.steamInit()
	var isRunning = Steam.isSteamRunning()

	if (!isRunning):
		print("Steam is not running.")
#		get_tree().quit()
#		return
	else:
		print("Steam is running.")
		var id = Steam.getSteamID()
		G.player_name = str(Steam.getFriendPersonaName(id))
		print("Your steam name: " + G.player_name)

	if G.files.get_json_from_dir(G.files.PLAYER_PATH) != null:
		on_start.call_deferred()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		_set_up_character($Peasant, head2, a_rags, null)
		_set_up_character($Warrior, head1, a_plate, a_sword)
		_set_up_character($Scholar, head2, a_yrobe, a_staff)
		_set_up_character($Rogue, head3, a_leather, a_dagger)
		_set_up_character($Hunter, head4, a_hunter, a_bow)
		_set_up_character($Barbarian, head3, a_hide, a_axe)
		_set_up_character($Druid, head5, a_grobe)
		_set_up_character($Necromancer, head6, a_suit)
		_set_up_character($Healer, head7, a_robe, a_mace)
		_set_up_character($Trainer, hcap, a_hide, null)
		$Canvas/CenterContainer/Settings.close.connect(on_ui_close)


func _set_up_character(node, head, armor, item=null):
	node.get_node("Model/Body/Head").set_cast_shadows_setting(true)
	node.get_node("Model/Body/Mesh").set_cast_shadows_setting(true)
	node.get_node("Model/Body/Head").set_mesh(head)
	node.get_node("Model/Body/Mesh").set_mesh(armor)
	node.get_node("Model/Item").mesh = item
	node.get_node("StaticBody3D").input_event.connect(on_input.bind(node))
	node.get_node("StaticBody3D").mouse_entered.connect(on_hover.bind(node))


func on_hover(node):
	if !_on:
		$SpotLight3D.position.x = node.position.x
		$SpotLight3D.position.z = node.position.z
		var dsc = desc.get(node.name)
		var txt = str("[center][color=DARK_CYAN][b]", node.name, "[/b][/color]\n")
		txt += str(dsc, "[/center]")
		set_text(txt)


func set_text(txt):
	$Canvas/Text.set_text(txt)


func on_input(_cam, _event: InputEvent, _pos, _normal, _shapeidx, _node):
	if _event is InputEventMouseButton:
		if !_on and _event.is_pressed():
			_chosen_class = _node.name.to_lower()
			$Canvas/ColorRect.show()
			G.sfx.play_bgm("dark", .3)
			$AnimationPlayer.play("fade")


func on_start():
	var root = get_tree().get_root()
	var level = self
	root.remove_child(level)
	level.call_deferred("free")
	var next_level_resource = load("res://game/game.tscn")
	var next_level = next_level_resource.instantiate()
	G.manual_ready(next_level)
	if _chosen_class != null:
		G.vars["name"] = _chosen_class
		G.ui.msg.call_deferred("Press F1 for controls.")
	root.add_child(next_level)


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if !_character_screen:
			_character_screen = true
			$AnimationPlayer.play("turn")
			set_text("")
	elif event is InputEventKey:
		if Input.is_action_just_pressed("ui_menu"):
			if _on:
				on_ui_close()
			else:
				_on = true
				$SpotLight3D.position.x = 900
				$Canvas/CenterContainer/Settings.show()
				$Canvas/CenterContainer/Settings.on_display()
		elif !_character_screen:
			_character_screen = true
			$AnimationPlayer.play("turn")
			set_text("")


func on_ui_close():
	_on = false
	$Canvas/CenterContainer/Settings.hide()

