extends "res://game/units/unit.gd"

const Hand = preload("../../items/hand.gd")

var held_item = null
var held_item_model
var _weapon_callback
var _previous_held
var hand

@onready var equipment = $Equipment

func _ready():
	super()
	equipment.set_unit(self)
	equipment.connect("selected", Callable(self, "_on_held_select"))
	action.bind("use_start", Callable(equipment, "use_held").bind(false))
	action.bind("use2_start", Callable(equipment, "use_held").bind(true))
	held_item_model = $Model/Item
	hand = Hand.new()


func _physics_process(delta):
	super(delta)
	if _weapon_callback != null:
		_weapon_callback.call(self)


func get_item_position():
	return held_item_model.global_position


func _on_held_select():
	var item = equipment.get_item_by_index(equipment.get_held_index())
	if item != _previous_held:
		if _previous_held != null:
			_previous_held.on_unheld(self)
		_previous_held = item
		if item != null:
			item.on_held(self)
	if item == null:
		held_item_model.hide()
		_weapon_callback = Callable(hand, "on_held_tick")
	else:
		held_item_model.show()
		held_item_model.set_mesh(item.model)
		_weapon_callback = Callable(item, "on_held_tick")
