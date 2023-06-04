extends "../item.gd"


func imbue(_sd):
	pass


func spend(_user):
	var sd = get_seed() - 1
	if sd < 0:
		return false
	elif sd == 0:
		_user.equipment.free_item(self)
		queue_free()
	else:
		sid = str(get_display_name(), ":", sd)
	return true


func get_description():
	var r = super()
	return str(r, "\nAmount: ", get_seed())

