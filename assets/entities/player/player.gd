extends Entity
class_name Player;

signal roomChanged(room : Room);

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
var rotation_roomOffset := 0.0;

@export_group("Movement", "movement_")
@export var movement_thrustPower : float = 64.0;
@export var movement_dampening : float = 0.65:
	set(value):
		movement_dampening = value;
		linear_damp = movement_dampening;
		
@export_category("Other")
@export_group("Camera", "camera_")
@export var camera_cameraNode : Camera2D = null;
@export var camera_defaultZoom : float = 2.0;

@export_group("Bounds", "bounds_")
@export var bounds_timeout : float = 5.0;
@export var bounds_timeoutLabel : Label = null;
@onready var bounds_timer = bounds_timeout;
var bounds_lastSafePosition = Vector2.ZERO;

var room_current : Room = null;
var claw_enabled := false;

func _ready() -> void:
	body_shape_entered.connect(_on_body_shape_entered);
	roomChanged.connect(func(_room): rotation_bump = true);
	

var mousePosition := Vector2.ZERO;
func _input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion):
		mousePosition = (event as InputEventMouseMotion).position;
func getMouseGlobalPosition() -> Vector2:
	var rect := camera_cameraNode.get_viewport_rect();
	rect.size /= camera_cameraNode.zoom;
	rect.position += camera_cameraNode.global_position - (rect.size / 2);
	return (mousePosition / camera_cameraNode.zoom) + rect.position;


func _physics_process(delta: float) -> void:
	if (GameSettings.game_toggleHoldClaw):
		claw_enabled = Input.is_action_pressed("player_claw_toggle");
	elif (Input.is_action_just_pressed("player_claw_toggle")):
		claw_enabled = !claw_enabled;
		
	if (room_current != null):
		if (!room_current.containsPoint(global_position)):
			bounds_timer -= delta;
			if (bounds_timeoutLabel != null):
				bounds_timeoutLabel.get_parent().get_parent().visible = (bounds_timer < bounds_timeout - 1.0);
				bounds_timeoutLabel.text = "Out of bounds. Teleporting in %s seconds." % String.num(round(bounds_timer), 0);
			if (bounds_timer < 0.0):
				global_position = bounds_lastSafePosition;
				linear_velocity = Vector2.ZERO;
				angular_velocity = 0;
		else:
			bounds_timer = bounds_timeout;
			if (bounds_timeoutLabel != null):
				bounds_timeoutLabel.get_parent().get_parent().visible = false;
	
	handleRotation(delta);
	handleMovement(delta);
	
	if (room_current != null):
		room_current.clampCamera(global_position, camera_cameraNode, camera_defaultZoom);
		
	if (rotation_bump):
		rotation_bump = false;
		bumpRotation();

var rotation_bump := false;
func bumpRotation() -> void:
	var targetLookPosition := getMouseGlobalPosition();
	var targetLookDirection := (targetLookPosition - global_position).normalized();
	var targetLookAngle := atan2(targetLookDirection.x, -targetLookDirection.y);
	rotation_lockedOffset = rotation_offset - angle_difference(rotation - (rotation_offset + rotation_roomOffset), targetLookAngle) - rotation_roomOffset;

func handleRotation(delta : float) -> void:
	var targetLookPosition :=  getMouseGlobalPosition();
	var targetLookDirection := (targetLookPosition - global_position).normalized();
	var targetLookAngle := atan2(targetLookDirection.x, -targetLookDirection.y);
	if (claw_enabled):
		rotation_roomOffset = 0;
		rotation_lockedOffset = rotation_offset - angle_difference(rotation - (rotation_offset + rotation_roomOffset), targetLookAngle) - rotation_roomOffset;
		targetLookDirection = rotation_lastLookDirection;
		targetLookAngle = atan2(targetLookDirection.x, -targetLookDirection.y);
	else: 
		rotation_lastLookDirection = targetLookDirection;
		rotation_offset = rotation_lockedOffset if GameSettings.game_keepClawForward else 0.0;
	#
	var error := angle_difference(rotation - (rotation_offset + rotation_roomOffset), targetLookAngle);
	
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
	
func handleMovement(_delta : float) -> void:
	var movementInput := Vector2(
		Input.get_axis("player_move_left", "player_move_right"),
		Input.get_axis("player_move_forward", "player_move_backward")
	).normalized();
	
	apply_force(movementInput * movement_thrustPower);

func _on_body_shape_entered(_body_rid: RID, _body: Node, _body_shape_index: int, _local_shape_index: int):
	#Console.printSuccess(body_rid, " ", body, " ", body_shape_index, " ", local_shape_index);
	# TODO: ?
	pass;
