extends CharacterBody3D

@onready var anim_player: AnimationPlayer = $Mesh/AnimationPlayer
@onready var state_machine: StateMachine = $StateMachine
@onready var detection_area: Area3D = $PlayerDetectionRadius
@onready var wall_detector: Area3D = $WallDetector

# --- Configurable Parameters ---
@export var speed: float = 3.0
@export var max_acceleration: float = 8.0
@export var max_deceleration: float = 6.0
@export var turn_speed: float = 6.5
@export var idle_time_min: float = 1.0
@export var idle_time_max: float = 2.0
@export var wander_radius: float = 20.0
@export var ground_attack_distance: float = 6.5
@export var attack_cooldown: float = 1.5
@export var attack_hesitation_time: float = 0.5

# --- Runtime Vars ---
var home_position: Vector3
var velocity_target: Vector3 = Vector3.ZERO
var wander_direction: Vector3 = Vector3.ZERO
var attack_cooldown_timer: float = 0.0
var is_attacking: bool = false
var target_player: Node3D = null

func _ready() -> void:
	home_position = global_position
	anim_player.animation_finished.connect(_on_animation_finished)

	# Player detection
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

	# Wall/corner detection
	wall_detector.body_entered.connect(_on_wall_entered)
	wall_detector.body_exited.connect(_on_wall_exited)

func _physics_process(delta: float) -> void:
	attack_cooldown_timer = max(0.0, attack_cooldown_timer - delta)

	# Run current FSM state
	state_machine.physics_update(delta)

	# Smooth movement
	velocity.x = move_toward(velocity.x, velocity_target.x, (max_acceleration if abs(velocity_target.x) > 0 else max_deceleration) * delta)
	velocity.z = move_toward(velocity.z, velocity_target.z, (max_acceleration if abs(velocity_target.z) > 0 else max_deceleration) * delta)
	move_and_slide()

func _rotate_toward(dir: Vector3, delta: float) -> void:
	var move_dir = Vector3(dir.x, 0, dir.z)
	if move_dir.length() > 0.1:
		rotation.y = lerp_angle(rotation.y, atan2(-move_dir.x, -move_dir.z), turn_speed * delta)

func _pick_new_direction() -> void:
	var angle = randf_range(0, TAU)
	wander_direction = Vector3(sin(angle), 0, cos(angle))
	if (global_position - home_position).length() > wander_radius:
		wander_direction = (home_position - global_position).normalized()

func _on_animation_finished(anim_name: String) -> void:
	if anim_name.begins_with("attack"):
		is_attacking = false

# --- Player Detection ---
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		target_player = body
		state_machine.transition_to("Hesitate")

func _on_body_exited(body: Node) -> void:
	if body == target_player:
		target_player = null
		state_machine.transition_to("Idle")

# --- Wall / Corner Detection ---
var wall_blocked: bool = false

func _on_wall_entered(body: Node) -> void:
	if body.is_in_group("Wall"):  # assign walls to a "Wall" group
		wall_blocked = true

func _on_wall_exited(body: Node) -> void:
	if body.is_in_group("Wall"):
		wall_blocked = false

# Call this in your Wander state physics_update:
func check_wall_and_rotate(delta: float) -> void:
	if wall_blocked:
		# Turn away from wall smoothly
		rotation.y += turn_speed * delta
		# Optionally pick a new wander direction
		_pick_new_direction()
