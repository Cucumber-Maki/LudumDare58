extends Entity;

func _ready() -> void:
	onDeath.connect(func(): queue_free());
