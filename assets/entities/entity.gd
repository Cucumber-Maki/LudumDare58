extends RigidBody2D
class_name Entity

signal onDeath()

@export_group("Health", "health_")
@export var health_max := 10.0;
@onready var health_current = health_max;

func takeDamage(damage : float) -> void: 
	if (health_current <= 0): return;
	health_current -= damage;
	if (health_current <= 0): onDeath.emit();
	Console.printError(self.name, " took ", damage, " damage.");
	pass;
