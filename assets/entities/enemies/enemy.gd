extends Entity;

@export_file("*.tscn") var projectile_scene : String;
@export var projectile_interval := 1.0;
@export var projectile_offset := 5.0;
@onready var projectiler_interval_timer := projectile_interval;

func _ready() -> void:
	onDeath.connect(func(): queue_free());

func _physics_process(delta: float) -> void:
	projectiler_interval_timer -= delta;
	if (projectiler_interval_timer > 0.0):
		return;
	projectiler_interval_timer = projectile_interval;
	
	if (projectile_scene == null): return;
	var projectile_packed := load(projectile_scene) as PackedScene;
	var projectile := projectile_packed.instantiate() as Projectile;
	projectile.side_player = false;
	projectile.global_rotation = global_rotation;
	projectile.global_position = global_position + (Vector2.from_angle(global_rotation) * projectile_offset);
	var partParent := get_parent() as RigidBody2D;
	if (partParent != null): 
		projectile.projectile_parentVelocity = partParent.linear_velocity;
	
	get_tree().get_current_scene().add_child(projectile);
