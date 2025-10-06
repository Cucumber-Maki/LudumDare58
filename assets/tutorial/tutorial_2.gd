extends Label

func _process(_delta: float) -> void:
	visible = Player.instance.claw_enabled;
