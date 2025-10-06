extends Entity;
class_name Enemy;

@export_group("Health", "health_")
@export var health_max := 10.0;
@onready var health_current = health_max;
const death_explosion = preload("res://assets/entities/explosion/explosion.tscn");

@export_group("AI", "ai_")
@export var ai_enabled := true;
@export var ai_wallDistance := 32.0;
@export var ai_approachDistance := 96.0;
@export var ai_retreatDistance := 24.0;
@export var ai_movementMultiplier := 1.0
@export var ai_wallForce := 4.0
@export var ai_retreatForce := 2.0;
@export var ai_approachForce := 2.0;
@export var ai_sideSpeed := 64.0;

@export_group("Projectile", "projectile_")
@export_file("*.tscn") var projectile_scene : String;
@export var projectile_interval := 1.0;
@export var projectile_offset := 5.0;
@onready var projectiler_interval_timer := randf() * projectile_interval;

@export_group("Rotation", "rotation_")
@export var rotation_term_p := 1.0;
@export var rotation_term_i := 0.5;
@export var rotation_term_d : = 0.8;
var rotation_integral := 0.0;
@onready var rotation_lastRotation := rotation

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
	if (ai_enabled): aiOne(delta);
	# TODO: Other styles of AI?
	
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
		
func handleRotation(targetLookPosition : Vector2, delta : float) -> void:
	var targetLookDirection := (targetLookPosition - global_position).normalized();
	var targetLookAngle := atan2(targetLookDirection.y, targetLookDirection.x);
	var error := angle_difference(rotation, targetLookAngle);
	#
	var rotationDelta := angle_difference(rotation_lastRotation, rotation) / delta;
	rotation_lastRotation = rotation;
	#
	rotation_integral = clampf(rotation_integral + (error * delta), -1.0 / rotation_term_i, 1.0 / rotation_term_i);
	var error_p := rotation_term_p * error;
	var error_i := rotation_term_i * rotation_integral;
	var error_d := rotation_term_d * rotationDelta;
	#
	var angularAcceleration := error_p + error_i + error_d;
	apply_torque((angularAcceleration - rotationDelta) / delta)

func aiOne(delta) -> void:
	var space_state = get_world_2d().direct_space_state;
	var forceAmount := Vector2.ZERO;
	
	const rayDirections := [ Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT ];
	for rayDirection in rayDirections:
		var query := PhysicsRayQueryParameters2D.create(global_position, global_position + (rayDirection * ai_wallDistance), 1);
		var result := space_state.intersect_ray(query);
		if (!result): 
			forceAmount += rayDirection * ai_wallDistance;
			continue;
		forceAmount += position - global_position;
	forceAmount *= ai_wallForce;
	
	var player := Player.instance;
	var player_to := player.global_position - global_position;
	var player_direction := player_to.normalized();
	var player_distance := player_to.length();
	
	
	if (player_distance < ai_retreatDistance):
		forceAmount += -player_direction * (ai_retreatDistance - player_distance) * ai_retreatForce;
	elif (player_distance > ai_approachDistance):
		forceAmount += player_direction * min((player_distance - ai_approachDistance) * ai_approachForce, 64);
	else:
		var player_perp := Vector2(player_direction.y, -player_direction.x);
		forceAmount += player_perp * sign(Vector2.from_angle(player.rotation).dot(player_direction)) * ai_sideSpeed;
	
	apply_force(forceAmount * ai_movementMultiplier);
	handleRotation(Player.instance.global_position, delta);
