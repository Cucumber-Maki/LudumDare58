extends Node2D

@export var listen_node : Node = null;
@export var listen_variable_max : StringName = "health_max";
@export var listen_variable_remaining : StringName = "health_remaining";

@onready var offset := position;

func _physics_process(_delta: float) -> void:
	if (listen_node == null || get_parent() == null): return;
	
	
	$ProgressBar.max_value = listen_node.get(listen_variable_max);
	$ProgressBar.value = listen_node.get(listen_variable_remaining);
	$ProgressBar.visible = $ProgressBar.value < $ProgressBar.max_value;
	
	global_position = get_parent().global_position + offset;
