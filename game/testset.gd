extends Node

var head1 = preload("res://assets/head/head1.obj")
var head2 = preload("res://assets/head/head2.obj")
var head3 = preload("res://assets/head/head3.obj")
var head4 = preload("res://assets/head/head4.obj")
var head5 = preload("res://assets/head/head5.obj")
var head6 = preload("res://assets/head/head6.obj")
var head7 = preload("res://assets/head/head7.obj")
var head8 = preload("res://assets/head/head8.obj")
var head9 = preload("res://assets/head/head9.obj")
var head10 = preload("res://assets/head/head10.obj")
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
var a_spear = preload("res://assets/weapon/spear3d-0-spear.obj")
var _character_screen = false
var _on = false
var _chosen_class

func _ready():
	_set_up_character($Warrior, head2, a_plate, a_sword)
	_set_up_character($Scholar, head4, a_yrobe, a_staff)
	_set_up_character($Rogue, head8, a_leather, a_dagger)
	_set_up_character($Hunter, head3, a_hunter, a_bow)
	_set_up_character($Barbarian, head5, a_hide, a_axe)
	_set_up_character($Priestess, head7, a_robe, a_mace)


func _set_up_character(node, head, armor, item=null):
	node.get_node("Model/Body/Head").set_cast_shadows_setting(true)
	node.get_node("Model/Body/Mesh").set_cast_shadows_setting(true)
	node.get_node("Model/Body/Head").set_mesh(head)
	node.get_node("Model/Body/Mesh").set_mesh(armor)
	node.get_node("Model/Item").mesh = item

