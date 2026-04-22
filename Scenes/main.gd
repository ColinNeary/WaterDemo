extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var cr = $Simulation/ColorRect
	var water = $Water
	var sim_tex = $Simulation.get_texture()
	var col_tex = $Collision.get_texture()
	
	water.mesh.surface_get_material(0).set_shader_parameter('simulation', sim_tex)
