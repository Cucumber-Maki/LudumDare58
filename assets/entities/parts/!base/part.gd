extends CollisionShape2D
class_name Part;

signal onJoin();
signal onDetach();

@export var health_max := 5.0;
@onready var health_remaining := 5.0;
var health_regenTimer := 0.0;

@export var rotation_random := true;

var m_connectedParent : Part = null;
var m_rigidBody : RigidBody2D = null;

func _ready() -> void:
	var collider : CollisionShape2D = CollisionShape2D.new();
	collider.shape = shape.duplicate();
	$PartGrab.add_child(collider)
	collider.debug_color = Color.ORANGE;
	collider.debug_color.a = 0.5;
	
	if (rotation_random):
		rotation = randf() * TAU;
	
	call_deferred("detach");

func _physics_process(delta: float) -> void:
	
	if (health_regenTimer > 0.0):
		health_regenTimer -= delta;
	elif (health_remaining < health_max && (get_parent() as Player == null)):
		health_remaining = move_toward(health_remaining, health_max, delta * 0.2);
	
	var parent := get_parent() as RigidBody2D;
	if (parent == null):
		detach();
		return;

func join(parent : RigidBody2D, joinable : bool, connectionOrigin : Vector2 = parent.global_position) -> void:
	var siblings : Array[Part];
	for child in get_parent().get_children():
		var part := child as Part;
		if (part == null): continue;
		if (part.m_connectedParent != self): continue;
		siblings.append(part);
	
	if (parent != get_parent()):
		reparent(parent);
	parent.call_deferred("move_child", self, 0);
	drawConnection(connectionOrigin);
		
	$PartJoin.visible = joinable;
	
	if (m_rigidBody != null && m_rigidBody.get_child_count() <= 0):
		m_rigidBody.queue_free();
	m_rigidBody = parent;
	
	for sibling in siblings:
		sibling.join(parent, joinable, self.global_position);

	onJoin.emit();
	var player := parent as Player;
	$Cover.visible = player == null;
	if (player != null):
		player.onPartJoin.emit(self);

func detach() -> void:
	drawConnectionClear();
	
	m_connectedParent = null;
	$PartJoin.visible = false;
	#m_connectableShapes.clear();
	
	var scene := get_tree().get_current_scene();
	if (get_parent() == m_rigidBody && get_parent().get_child_count() <= 1):
		return;
		
	var siblings : Array[Part];
	for child in get_parent().get_children():
		var part := child as Part;
		if (part == null): continue;
		if (part.m_connectedParent != self): continue;
		siblings.append(part);
		
	m_rigidBody = RigidBody2D.new();
	m_rigidBody.collision_layer = 32;
	m_rigidBody.collision_mask = 1 | 2 | 8 | 32;
	m_rigidBody.linear_damp = 0.7;
	scene.add_child(m_rigidBody);
	scene.move_child(m_rigidBody, 0);
	
	m_rigidBody.global_position = global_position;
	reparent(m_rigidBody);
		
	for sibling in siblings:
		sibling.join(m_rigidBody, false);
		
	onDetach.emit();
	$Cover.visible = true;

func takeDamage(damage : float) -> void:
	health_remaining -= damage;
	health_regenTimer = 3.0;
	if (health_remaining > 0.0): return;
	detach();

func drawConnection(target : Vector2, onTop : bool = false) -> void:
	var difference := target - global_position;
	$PartConnection.look_at(target);
	$PartConnection.rotate(PI * 0.5)
	$PartConnection.scale.y = difference.length() / 16;
	$PartConnection.z_index = 2 if onTop else 0;
	
func drawConnectionClear() -> void:
	$PartConnection.scale.y = 0;
	
var m_connectableShapes: Array[CollisionShape2D] = [];
func _on_partjoin_area_shape_entered(_area_rid: RID, area: Area2D, area_shape_index: int, _local_shape_index: int) -> void:
	var joinShape := area.get_child(area_shape_index) as CollisionShape2D;
	if (joinShape == null): return;
	if (m_connectableShapes.has(joinShape)): return;
	m_connectableShapes.append(joinShape);
	
func _on_partjoin_area_shape_exited(_area_rid: RID, area: Area2D, area_shape_index: int, _local_shape_index: int) -> void:
	var joinShape := area.get_child(area_shape_index) as CollisionShape2D;
	if (joinShape == null): return;
	m_connectableShapes.erase(joinShape);

func getBestConnectableShape() -> CollisionShape2D:
	var bestShape : CollisionShape2D = null;
	var closestDist := INF;
	
	for collisionShape : CollisionShape2D in m_connectableShapes:
		if (!collisionShape.get_parent().visible): continue;
		var distance : float = (collisionShape.global_position - global_position).length();
		if (bestShape != null && closestDist <= distance): continue;
		bestShape = collisionShape;
		closestDist = distance;
	
	return bestShape;
