extends CanvasLayer

var sim_mat: ShaderMaterial
var water_mat: ShaderMaterial

func _ready():
	sim_mat   = get_node("../Simulation/ColorRect").material as ShaderMaterial
	water_mat = get_node("../Water").mesh.surface_get_material(0) as ShaderMaterial

	var panel = PanelContainer.new()
	panel.position = Vector2(20, 20)
	add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(220, 0)
	panel.add_child(vbox)

	var title = Label.new()
	title.text = "Water Controls"
	title.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title)

	add_separator(vbox)

	# sim_mat params match simulation.gdshader uniform names
	# water_mat params match main.tres VisualShader parameter names
	add_slider(vbox, "Wave Speed",      "phase",               0.05,  0.4,    0.01,   0.2,   sim_mat)
	add_slider(vbox, "Wave Height",     "amplitude",           0.0,   1.0,    0.01,   0.5,   water_mat)
	add_slider(vbox, "Refraction",      "refraction_strength", 0.0,   2.0,    0.05,   1.0,   water_mat)
	add_slider(vbox, "Dampening",       "attenuation",         0.990, 0.9999, 0.0001, 0.999, sim_mat)
	add_slider(vbox, "Wave Amplitude",  "wave_amplitude",      0.0,   0.15,   0.005,  0.08,  sim_mat)
	add_slider(vbox, "Wave Frequency",  "wave_frequency",      1.0,   20.0,   0.5,    6.0,   sim_mat)


func add_slider(parent, label_text, param, min_v, max_v, step, default, mat):
	var label = Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", 13)
	parent.add_child(label)

	var hbox = HBoxContainer.new()
	parent.add_child(hbox)

	var slider = HSlider.new()
	slider.min_value = min_v
	slider.max_value = max_v
	slider.step = step
	slider.value = default
	slider.custom_minimum_size = Vector2(170, 20)
	hbox.add_child(slider)

	var val_label = Label.new()
	val_label.text = str(snappedf(default, step))
	val_label.custom_minimum_size = Vector2(45, 0)
	val_label.add_theme_font_size_override("font_size", 11)
	hbox.add_child(val_label)

	slider.value_changed.connect(func(v):
		if mat != null:
			mat.set_shader_parameter(param, v)
		val_label.text = str(snappedf(v, step))
	)

	add_separator(parent)


func add_separator(parent):
	var sep = HSeparator.new()
	parent.add_child(sep)
