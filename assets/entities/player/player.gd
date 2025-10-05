extends RigidBody2D
class_name Player;

@export_category("Movement Characteristics")
@export_group("Rotation", "rotation_")
@export var rotation_term_p := 1.5;
@export var rotation_term_i := 0.5;
@export var rotation_term_d : = 0.8;
var rotation_integral := 0.0;
@onready var rotation_lastRotation : = rotation
var rotation_lastLookDirection := Vector2.ZERO;
var rotation_offset := 0.0;
var rotation_lockedOffset := 0.0;

@export_group("Movement", "movement_")
@export var movement_thrustPower : float = 64.0;
@export var movement_dampening : float = 0.65:
	set(value):
		movement_dampening = value;
		linear_damp = movement_dampening;

var claw_enabled := false;

func _ready() -> void:
	body_shape_entered.connect(_on_body_shape_entered);

func _physics_process(delta: float) -> void:
	if (GameSettings.game_toggleHoldClaw):
		claw_enabled = Input.is_action_pressed("player_claw_toggle");
	elif (Input.is_action_just_pressed("player_claw_toggle")):
		claw_enabled = !claw_enabled;
		
	handleRotation(delta);
	handleMovement(delta);

func handleRotation(delta : float) -> void:
	var targetLookPosition := get_global_mouse_position();
	var targetLookDirection := (targetLookPosition - global_position).normalized();
	var targetLookAngle := atan2(targetLookDirection.x, -targetLookDirection.y);
	if (claw_enabled):
		rotation_lockedOffset = rotation_offset - angle_difference(rotation - rotation_offset, targetLookAngle);
		targetLookDirection = rotation_lastLookDirection;
		targetLookAngle = atan2(targetLookDirection.x, -targetLookDirection.y);
	else: 
		rotation_lastLookDirection = targetLookDirection;
		rotation_offset = rotation_lockedOffset if GameSettings.game_keepClawForward else 0.0;
	#
	var error := angle_difference(rotation - rotation_offset, targetLookAngle);
	
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
	angular_velocity = angularAcceleration;
	
func handleMovement(_delta : float) -> void:
	var movementInput := Vector2(
		Input.get_axis("player_move_left", "player_move_right"),
		Input.get_axis("player_move_forward", "player_move_backward")
	).normalized();
	
	apply_force(movementInput * movement_thrustPower);

func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int):
	#Console.printSuccess(body_rid, " ", body, " ", body_shape_index, " ", local_shape_index);
	# TODO: ?
	pass;
