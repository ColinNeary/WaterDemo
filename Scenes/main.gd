extends Node3D

func _ready():
	# Step 1: Remove the water_surface.gdshader override so the original
	# VisualShader (main.tres) on the PlaneMesh is used instead
	$Water.set_surface_override_material(0, null)
	
	# Step 2: Get the SubViewport output textures
	var sim_tex = $Simulation.get_texture()  # wave height field output
	var col_tex = $Collision.get_texture()   # ball position for collision
	
	# Step 3: Wire the simulation shader feedback loop
	# sim_tex feeds back into itself (previous frame → current frame)
	# col_tex tells the shader where the ball is touching water
	var sim_mat = $Simulation/ColorRect.material as ShaderMaterial
	sim_mat.set_shader_parameter("sim_tex", sim_tex)
	sim_mat.set_shader_parameter("col_tex", col_tex)
	
	# Step 4: Pass the simulation output to the water surface VisualShader
	# This uses the original main.tres shader (inside the PlaneMesh material)
	var water_mat = $Water.mesh.surface_get_material(0) as ShaderMaterial
	water_mat.set_shader_parameter("simulation", sim_tex)
