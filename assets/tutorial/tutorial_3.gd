extends Label

func _process(_delta: float) -> void:
	visible = (Player.instance.find_child("Claw") as Claw).m_grippedPart != null;
