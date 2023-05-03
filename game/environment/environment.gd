extends Node

@onready var _light = get_node("../DirectionalLight3D")
@onready var _player_light = get_node("../Player/Unit/OmniLight3D")
@onready var _env = get_node("../WorldEnvironment").environment
@onready var _sky = preload("res://game/environment/sky_material.tres")
@onready var _gradient_sky = preload("res://game/environment/time_sky_gradient.tres")
@onready var _gradient_light = preload("res://game/environment/time_light_gradient.tres")
@onready var _gradient_ground = preload("res://game/environment/time_ground_gradient.tres")


func _process(delta):
	_light.transform.basis = _light.transform.basis.rotated(Vector3.RIGHT, 0.002 * delta)
	var sun_angle = _light.transform.basis.z[1]
	if sun_angle < .1:
		var v = max(0, (sun_angle - .05) * 5)
		_light.light_energy = v
		_env.ambient_light_energy = v
		_player_light.omni_range = 28 * v + 4
	var light_color = _gradient_light.sample(sun_angle)
	var sky_color = _gradient_sky.sample(sun_angle)
	var ground_color = _gradient_ground.sample(sun_angle)
	_sky.sky_top_color = sky_color
	_sky.sky_horizon_color = light_color
	_sky.ground_horizon_color = light_color
	_sky.ground_bottom_color = ground_color
	_light.light_color = light_color
#	RenderingServer.global_shader_parameter_set("background", light_color)

