extends Node3D

var _lifetime = 1.0


func _ready():
	$SubViewport.set_update_mode(SubViewport.UPDATE_WHEN_PARENT_VISIBLE)
	var mat = $GPUParticles3D.draw_pass_1.material
	mat.albedo_texture = $SubViewport.get_texture()
	$GPUParticles3D.emitting = true


func set_text(p):
	$SubViewport/Label.set_text(p)


func _process(delta: float):
	_lifetime -= delta
	if _lifetime <= 0:
		queue_free()
		return

