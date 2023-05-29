extends Node

signal special

const Laser = preload("../../items/weapon/projectile/laser.tscn")
const Bomb = preload("./bomb.tscn")
var _unit
var _param


func set_unit(p):
	_unit = p
	_unit.attacked.connect(on_hit)
	_unit.wait.connect(on_wait)


func on_touch():
	if !perform("earth"):
		if !perform("bomb"):
			perform("psychic")

func on_wait():
	perform("shadow")

func on_hit():
	perform("warrior")

func on_attack(_victim):
	_param = _victim
	perform("vampire")
	perform("goblin")


func perform(ess):
	if ess in _unit.essence:
		if ess == "warrior":
			return recover(4, 30)
		elif !_unit.buffs.has("exhaustion"):
			if ess == "earth":
				return passwall()
			elif ess == "bomb":
				return plant_bomb()
			elif ess == "psychic":
				return psychic()
			elif ess == "shadow":
				return invisibility()
			elif ess == "goblin":
				return slow(3)
			elif ess == "vampire":
				return recover(1, 8)
	return false


func slow(p):
	_param.buffs.add("slow", p)


func recover(regen, cd):
	if !_unit.buffs.has("regeneration cooldown"):
		_unit.buffs.add("regeneration", regen)
		_unit.buffs.add("regeneration cooldown", cd)


func invisibility():
	_unit.buffs.add("invisibility", 3)


func psychic():
	var anim_name = "shoot"
	var animation = _unit.animator.get_animation(anim_name)
	if animation != null:
		var anim_dur = animation.get_length()
		_unit.animator.seek(0, true)
		_unit.animator.play(anim_name)
		_unit.action.force_set_next("use", anim_dur * .5 - .1, psychic_shoot)
		_unit.action.show_progress = true
		_unit.action.cancelable = true
		_unit.buffs.add("exhaustion", 4)


func psychic_shoot():
	emit_signal("special", "psych")
	var rocket = Laser.instantiate()
	rocket.damage = 7
	rocket.position = _unit.get_center()
	G.stock.add_child(rocket)
	rocket.set_direction(_unit.forward)
	_unit.action.set_next("idle", .5)


func plant_bomb():
	var hit = G.tool.raycast(_unit.camera.global_position, _unit.forward, 1.5, 4)
	if hit != null:
		emit_signal("special", "psych")
		var bomb = Bomb.instantiate()
		var dest = hit.previous_position
		bomb.position = dest
		G.tool.set_voxel(dest, 3)
		G.stock.add_child(bomb)
		_unit.buffs.add("exhaustion", 10)
		return true


func passwall():
	if _unit == G.you:
		var cardinal = G.tool.cardinalize(_unit.forward)
		var dest = _unit.position.floor() + G.V2_HALF + cardinal * 2
		if G.tool.get_voxel(dest) == 0 and G.tool.get_voxel(dest + Vector3.UP) == 0 and G.tool.get_voxel(dest + Vector3.DOWN) != 0:
			emit_signal("special", "earth")
			dest += cardinal * .5
			_unit.action.set_next("passwall", 3, G.you.camera.set_override.bind(null))
			_unit.action.on_tick = passwall_tick.bind(_unit, dest)
			G.you.camera.zoom_distance(1)
			G.you.camera.set_override(G.you.camera.position)
			_unit.buffs.add("exhaustion", 4)
			return true
func passwall_tick(_user, to):
	_user.position = _user.position.lerp(to, 0.01)

