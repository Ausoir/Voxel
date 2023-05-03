extends Node


var vars
@onready var faction = $Faction
@onready var unit = $Unit


func _ready():
	unit.equipment.add_slot("armor")
	unit.equipment.wear(G.stock.get_item("jacket"))
	unit.equipment.pickup(G.stock.get_item("builder"))
	unit.equipment.pickup(G.stock.get_item("remover"))
	unit.equipment.pickup(G.stock.get_item("spawner"))
	unit.equipment.pickup(G.stock.get_item("rocket"))
	$Interface.set_unit(unit)
	$Save.load_data()
