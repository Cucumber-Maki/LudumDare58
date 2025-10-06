extends RigidBody2D
class_name Projectile;

@export var side_player := true:
	set(value):
		side_player = value;
		collision_mask = 1 | (2 if !side_player else 0) | (8 if side_player else 0);
		modulate = Color("ffbb33") if side_player else Color("ff0044");
		
@export var projectile_damage := 1.0;
@export var projectile_speed := 64.0;
@export var projectile_turn := 0.0;
@export var projectile_turnAcceleration := 0.0;
@export var projectile_turnMax := 0.0;
@export var projectile_parentVelocity := Vector2.ZERO;
@export var projectile_bounce := false;
@export var projectile_lifetime := 30.0;
var projectile_lifetime_timer := 0.0;

func _ready() -> void:
	projectile_turnAcceleration *= signf(randf_range(-1, 1));

func _physics_process(delta: float) -> void:
	angular_velocity = projectile_turn;
	projectile_turn = clampf(projectile_turn + (projectile_turnAcceleration * delta), -projectile_turnMax, projectile_turnMax);
	
	linear_velocity = (Vector2.from_angle(rotation) * projectile_speed) + projectile_parentVelocity;
	projectile_parentVelocity = projectile_parentVelocity.move_toward(Vector2.ZERO, delta);
	
	projectile_lifetime_timer += delta;
	if (projectile_lifetime_timer >= projectile_lifetime):
		queue_free();

func _on_body_shape_entered(_body_rid: RID, body: Node, body_shape_index: int, _local_shape_index: int) -> void:
	var rigidBody := body as RigidBody2D;
	if (rigidBody == null): 
		if (projectile_bounce):
			var state := PhysicsServer2D.body_get_direct_state(get_rid())
			var normal := state.get_contact_local_normal(0)
			var perp = Vector2(normal.y, -normal.x);
			
			var inDir := Vector2.from_angle(rotation);
			var outDir = inDir.reflect(perp);

			var newProjectile = self.duplicate();
			newProjectile.rotation = outDir.angle()
			newProjectile.global_position += outDir * 3;
			newProjectile.projectile_lifetime_timer = projectile_lifetime_timer;
			get_parent().call_deferred("add_child", newProjectile);
		queue_free();
		return;
	
	var entity := body as Entity;
	if (entity != null):
		# TODO: Damage.
		entity.onHit.emit(projectile_damage);
		var hitCollisionShape := body.shape_owner_get_owner(body.shape_find_owner(body_shape_index)) as CollisionShape2D;
		if (hitCollisionShape != null):
			entity.onHitShape.emit(projectile_damage, hitCollisionShape);
	queue_free();
