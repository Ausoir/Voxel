extends Node

@onready var _player_light = get_node("../Player/Unit/OmniLight3D")
@onready var _light = get_node("../DirectionalLight3D")
@onready var _env = get_node("../WorldEnvironment").environment
@onready var _sky = preload("res://game/environment/sky_material.tres")
@onready var _gradient_sky = preload("res://game/environment/time_sky_gradient.tres")
@onready var _gradient_horizon = preload("res://game/environment/time_horizon_gradient.tres")
@onready var _gradient_ground = preload("res://game/environment/time_ground_gradient.tres")
@onready var _gradient_water = preload("res://game/environment/time_water_gradient.tres")


func _process(delta):
	_light.transform.basis = _light.transform.basis.rotated(Vector3.RIGHT, 0.01 * delta)
	if _light.transform.basis.z[1] < .25:
		var v = max(0, (_light.transform.basis.z[1] - .05) * 5)
		_light.light_energy = v
		_light.light_indirect_energy = v
		_player_light.omni_range = 28 * v + 4
		_env.ambient_light_energy = 1-v
		_env.fog_density = .02 * (1-v)
		_env.fog_sky_affect = 1-v
	_sky.sky_top_color = _gradient_sky.sample(_light.transform.basis.z[1])
	_sky.sky_horizon_color = _gradient_horizon.sample(_light.transform.basis.z[1])
	_sky.ground_horizon_color = _gradient_ground.sample(_light.transform.basis.z[1])
	_sky.ground_bottom_color = _gradient_water.sample(_light.transform.basis.z[1])
	var oc = Vector3(_sky.ground_horizon_color.r, _sky.ground_horizon_color.g, _sky.ground_horizon_color.b)
	RenderingServer.global_shader_parameter_set("ocean_color", oc)
