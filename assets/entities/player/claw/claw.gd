extends Node2D
class_name Claw;

@export_group("Images", "image_")
@export var image_idle : Texture2D;
@export var image_open : Texture2D;
@export var image_closed : Texture2D;

@export_group("Arm", "arm_")
@export var arm_speed := 150.0;
@export var arm_connectDistance = 48.0;
@export var arm_maxGrabVelocity = 64.0;

@onready var m_player : Player = get_parent() as Player;
var m_grippedPart : Part = null;
var m_targetPosition := Vector2.ZERO; 
var m_targetLocalPosition := Vector2(16, 0);

func _physics_process(delta: float) -> void:
	handleClaw(delta);

func handleClaw(delta : float) -> void:
	if (m_player != null && !m_player.claw_enabled):
		$ClawHead.texture = image_idle;
		if (m_grippedPart != null):
			var connectableShape := m_grippedPart.getBestConnectableShape();
			m_grippedPart.drawConnectionClear();
			if (m_player != null && connectableShape != null):
				m_grippedPart.join(m_player, true, connectableShape.global_position);
				m_grippedPart.m_connectedParent = connectableShape.get_parent().get_parent() as Part;
			m_grippedPart = null;
		m_targetPosition = to_global(m_targetLocalPosition) - global_position;
		return;
		
	var lastTargetPosition = m_targetPosition;
	m_targetPosition = m_targetPosition.move_toward((get_global_mouse_position() - global_position), arm_speed * delta);
	var target := m_targetPosition + global_position;
	m_targetLocalPosition = to_local(target);
	
	var grippableObject := getBestGrippedObject();	
	var grippablePart := (grippableObject.get_parent() as Part) if (grippableObject != null) else null;
	
	if (m_grippedPart == null):
		if (Input.is_action_just_pressed("player_claw_grip") && grippablePart != null):
			m_grippedPart = grippablePart;
			m_grippedPart.detach();
		else:
			pass;
	if (m_grippedPart != null):
		var connectableShape := m_grippedPart.getBestConnectableShape();
		if (connectableShape != null):
			m_grippedPart.drawConnection(connectableShape.global_position, true);
		else:
			m_grippedPart.drawConnectionClear();
			
		if (!Input.is_action_pressed("player_claw_grip") || grippablePart == null):
			m_grippedPart.drawConnectionClear();
			if (m_player != null && connectableShape != null):
				m_grippedPart.join(m_player, true, connectableShape.global_position);
				m_grippedPart.m_connectedParent = connectableShape.get_parent().get_parent() as Part;
			m_grippedPart = null;
			
		else:
			var current := m_grippedPart.m_rigidBody.global_position;
			var difference := target - current;
			var collision := m_grippedPart.m_rigidBody.move_and_collide(difference, true);
			if (collision != null): 
				difference = collision.get_travel();
				m_targetPosition = lastTargetPosition.lerp(m_targetPosition, 0.25);
			target = (current + difference).lerp(target, 0.5);
			# Clamp force.
			difference = difference.normalized() * min(difference.length(), arm_maxGrabVelocity);
			m_grippedPart.m_rigidBody.linear_velocity = difference / delta;
			m_grippedPart.m_rigidBody.apply_torque(1);
		pass;
	
	look_at(target);
	$GripArea.global_position = target;
	
	var relative := target - global_position;
	var targetLen := relative.length();
	var headLen := targetLen - 9;
	
	$ClawArm.visible = true;
	$ClawArm.scale.y = headLen / 16;
	$ClawHead.position.x = headLen;
	
	if (m_grippedPart != null):
		$ClawHead.texture = image_closed;
	elif (grippablePart != null):
		$ClawHead.texture = image_open;
	else:	
		$ClawHead.texture = image_idle;
		

var activeBodies : Array[CollisionObject2D] = [];
func _on_grip_area_entered(body: Node2D) -> void:
	var collisionObject := body as CollisionObject2D;
	if (activeBodies.has(collisionObject)): return;
	activeBodies.append(collisionObject);
func _on_grip_area_exited(body: Node2D) -> void:
	activeBodies.erase(body);

func getBestGrippedObject() -> CollisionObject2D:
	var bestBody : CollisionObject2D = null;
	var closestDist := INF;
	
	for collisionObject : CollisionObject2D in activeBodies:
		var distance : float = (collisionObject.global_position - $GripArea.global_position).length();
		if (bestBody != null && closestDist <= distance): continue;
		bestBody = collisionObject;
		closestDist = distance;
	
	return bestBody;
