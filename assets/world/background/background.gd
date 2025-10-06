extends Node2D

func _process(_delta: float) -> void:
	global_rotation = 0;
	const layerMultiplier := 1.0 / 800.0;
	$Layer1.set_instance_shader_parameter("GlobalPosition", global_position);
	$Layer1.set_instance_shader_parameter("ParallaxFactor", layerMultiplier * 0.02);
	$Layer2.set_instance_shader_parameter("GlobalPosition", global_position);
	$Layer2.set_instance_shader_parameter("ParallaxFactor", layerMultiplier * 0.04);
	$Layer3.set_instance_shader_parameter("GlobalPosition", global_position);
	$Layer3.set_instance_shader_parameter("ParallaxFactor", layerMultiplier * 0.08);
