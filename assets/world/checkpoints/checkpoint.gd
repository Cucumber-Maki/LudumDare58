extends Area2D

func _on_body_entered(body: Node2D) -> void:
	var player := body as Player;
	if (player == null): return;
	
	player.bounds_lastSafePosition = global_position;
