extends Entity;
class_name Enemy;

@export_group("Health", "health_")
@export var health_max := 10.0;
@onready var health_current = health_max;
const death_explosion = preload("res://assets/entities/explosion/explosion.tscn");

@export_file("*.tscn") var projectile_scene : String;
@export var projectile_interval := 1.0;
@export var projectile_offset := 5.0;
@onready var projectiler_interval_timer := projectile_interval;

func _ready() -> void:
	call_deferred("bindRoomCheck");
	onHit.connect(takeDamage);
	onDeath.connect(func(): 
		var explosion := death_explosion.instantiate() as Node2D;
		explosion.global_position = global_position;
		get_tree().current_scene.add_child(explosion);
		)
	process_mode = Node.PROCESS_MODE_DISABLED;

func _physics_process(delta: float) -> void:
	projectiler_interval_timer -= delta;
	if (projectiler_interval_timer > 0.0):
		return;
	projectiler_interval_timer = projectile_interval;
	
	if (projectile_scene == null || projectile_scene == ""): return;
	var projectile_packed := load(projectile_scene) as PackedScene;
	var projectile := projectile_packed.instantiate() as Projectile;
	projectile.side_player = false;
	projectile.global_rotation = global_rotation;
	projectile.global_position = global_position + (Vector2.from_angle(global_rotation) * projectile_offset);
	var partParent := get_parent() as RigidBody2D;
	if (partParent != null): 
		projectile.projectile_parentVelocity = partParent.linear_velocity;
	
	get_tree().get_current_scene().add_child(projectile);

func takeDamage(damage : float) -> void: 
	if (health_current <= 0): return;
	health_current -= damage;

	if (health_current > 0): return;
	onDeath.emit();
	queue_free();
	
func bindRoomCheck():
	onRoomChanged.connect(checkRoom);
	Player.instance.onRoomChanged.connect(checkRoom);
	checkRoom();
	
func checkRoom():
	if (Player.instance.room_current == room_current):
		process_mode = Node.PROCESS_MODE_INHERIT;
	else: 
		process_mode = Node.PROCESS_MODE_DISABLED;
