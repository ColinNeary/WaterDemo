extends Node3D

var _underwater_mat: ShaderMaterial

func _ready():
	var sim_tex = $Simulation.get_texture()
	var col_tex = $Collision.get_texture()

	# Wire simulation feedback loop
	var sim_mat = $Simulation/ColorRect.material as ShaderMaterial
	sim_mat.set_shader_parameter("sim_tex", sim_tex)
	sim_mat.set_shader_parameter("col_tex", col_tex)

	# Use the existing main.tres material — simulation is already wired in Water.tscn
	# Re-affirm here in case the viewport path needs a runtime push
	var water_mat = $Water.mesh.surface_get_material(0) as ShaderMaterial
	if water_mat:
		water_mat.set_shader_parameter("simulation", sim_tex)

	# PostProcess underwater effect (optional — safe if node missing)
	var effect = get_node_or_null("PostProcess/UnderwaterEffect")
	if effect != null:
		effect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_underwater_mat = effect.material

func _process(_delta):
	if _underwater_mat == null:
		return
	var cam = get_node("Main Camera")
	var intensity = clamp(($Water.global_position.y - cam.global_position.y) / 2.0, 0.0, 1.0)
	_underwater_mat.set_shader_parameter("intensity", intensity)
