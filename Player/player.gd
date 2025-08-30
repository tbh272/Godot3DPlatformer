extends CharacterBody3D

@export_group("Movement")
@export var speed: float = 9.0
@export var run_speed: float = 13.0
@export var acceleration: float = 75.0
@export var deceleration: float = 120.0
@export var air_control: float = 0.6

@export_group("Jump")
@export var jump_velocity: float = 6.5
@export var jump_gravity_reduction: float = 0.9
@export var jump_hold_time: float = 0.2
@export var coyote_time: float = 0.3
@export var jump_buffer_time: float = 0.1
@export var soft_landing_threshold: float = 5.0

@export_group("Combat")
@export var attack_damage: float = 15.0

@export_group("Dodge")
@export var dodge_distance: float = 18.0
@export var dodge_duration: float = 1.4
@export var sidestep_distance: float = 3.0
@export var sidestep_duration: float = 0.2
@export var block_speed: float = 2.5

# --- Constants ---
const TURN_SPEED: float = 20.0

# --- Node References ---
@onready var camera: Node3D = $SpringArm3D/Camera3D
@onready var anim_player: AnimationPlayer = $Mesh/AnimationPlayer
@onready var mesh: Node3D = $Mesh
@onready var hitbox: Area3D = $Mesh/Rig/Skeleton3D/BoneAttachment3D/Sword/Hitbox
@onready var state_machine: Node = $StateMachine
@onready var health_component: HealthComponent = $HealthComponent

# --- Runtime Variables ---
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var jump_held_time: float = 0.0
var dodge_timer: float = 0.0
var dodge_direction: Vector3 = Vector3.ZERO
var max_air_y: float = 0.0
var fall_height: float = 0.0
var input_dir: Vector2 = Vector2.ZERO
var direction: Vector3 = Vector3.ZERO
var input_magnitude: float = 0.0
var just_landed: bool = false
var just_left_ground: bool = false
var hit_entities: Array[Node] = []

func _ready() -> void:
	# Validate node references
	if not camera or not anim_player or not mesh or not state_machine: ## or not hitbox 
		push_error("Required nodes missing. Check scene setup.")
		set_physics_process(false)
		return

	# Connect signals
	anim_player.animation_finished.connect(_on_animation_finished)
	hitbox.body_entered.connect(_on_hitbox_body_entered) ##fix later
	hitbox.monitoring = false

	# Initialize position tracking
	max_air_y = global_position.y

func _physics_process(delta: float) -> void:
	# Update input
	_update_input()

	# Handle gravity and timers
	_update_gravity_and_timers(delta)

	# Track floor state
	var prev_on_floor: bool = is_on_floor()
	just_landed = false
	just_left_ground = false

	# Update state machine
	if state_machine.has_method("physics_update"):
		state_machine.physics_update(delta)
	else:
		push_warning("StateMachine lacks physics_update method.")

	# Apply movement
	move_and_slide()

	# Update floor state transitions
	just_landed = is_on_floor() and not prev_on_floor
	just_left_ground = not is_on_floor() and prev_on_floor

	# Update fall height
	_update_fall_height()

	# Handle landing transitions
	if just_landed and state_machine.current_state.name in ["Jump", "Fall", "Attack"]:
		var landing_anim: String = "Jump_Land" if fall_height < soft_landing_threshold else "Hard_Land"
		state_machine.transition_to("Landing"+ landing_anim)

func _update_input() -> void:
	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	direction = (camera.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	input_magnitude = input_dir.length()

func _update_gravity_and_timers(delta: float) -> void:
	if not is_on_floor():
		var gravity_mult: float = jump_gravity_reduction if (state_machine.current_state.name == "Jump" and Input.is_action_pressed("ui_accept") and jump_held_time < jump_hold_time) else 1.0
		velocity += get_gravity() * gravity_mult * delta
	else:
		coyote_timer = coyote_time

	# Update timers
	coyote_timer = max(coyote_timer - delta, 0.0)
	jump_buffer_timer = max(jump_buffer_timer - delta, 0.0) if not Input.is_action_just_pressed("jump") else jump_buffer_time

func _update_fall_height() -> void:
	if just_left_ground:
		max_air_y = global_position.y
	elif not is_on_floor():
		max_air_y = max(max_air_y, global_position.y)
	if just_landed:
		fall_height = max_air_y - global_position.y

func apply_movement(delta: float, speed_multiplier: float = 1.0, use_block_speed: bool = false) -> void:
	var target_speed: float = block_speed if use_block_speed else speed * input_magnitude * speed_multiplier
	var accel: float = acceleration if input_magnitude > 0 else deceleration
	if not is_on_floor():
		accel *= air_control
	velocity.x = move_toward(velocity.x, direction.x * target_speed, accel * delta)
	velocity.z = move_toward(velocity.z, direction.z * target_speed, accel * delta)

func apply_dodge_movement(delta: float) -> void:
	dodge_timer = max(dodge_timer - delta, 0.0)
	velocity.x = dodge_direction.x
	velocity.z = dodge_direction.z

func turn_to_direction(aim_dir: Vector3, delta: float) -> void:
	if aim_dir.length_squared() > 0.01:
		var yaw: float = atan2(-aim_dir.x, -aim_dir.z)
		rotation.y = lerp_angle(rotation.y, yaw, TURN_SPEED * delta)

func get_mouse_world_direction() -> Vector3:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var ray_origin: Vector3 = camera.project_ray_origin(mouse_pos)
	var ray_dir: Vector3 = camera.project_ray_normal(mouse_pos)
	var plane: Plane = Plane(Vector3.UP, global_position.y)
	var hit = plane.intersects_ray(ray_origin, ray_dir)
	return (hit - global_position).normalized() if hit else Vector3.ZERO

func start_dodge(dir: Vector3, is_sidestep: bool = false) -> void:
	var distance: float = sidestep_distance if is_sidestep else dodge_distance
	var duration: float = sidestep_duration if is_sidestep else dodge_duration
	var effective_dir: Vector3 = dir if dir.length_squared() > 0.01 else -transform.basis.z
	dodge_direction = effective_dir.normalized() * (distance / duration)
	dodge_timer = duration

func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		"Jump_Land", "Hard_Land":
			var next_state: String = "Walk" if input_magnitude > 0.1 else "Idle"
			state_machine.transition_to(next_state)
		"Sword_Attack":
			#hitbox.monitoring = false
			hit_entities.clear()
			var next_state: String = "Walk" if input_magnitude > 0.1 else "Idle"
			state_machine.transition_to(next_state)

func take_damage(amount: float) -> void:
	# Check if in Block state
	if state_machine.current_state and state_machine.current_state.name == "Block":
		print("Damage blocked!")
		# Optional: Play block impact animation or effect
		if anim_player and anim_player.has_animation("Block_Hit"):
			anim_player.play("Block_Hit")
		return  # Skip damage
	# Apply damage if not blocking
	health_component.health -= amount
	if health_component.health <= 0: ## handle death logic here and animation in the state machine
		state_machine.transition_to("Death")
		health_component.die()
	else:
		# Optional: Play hurt animation or flash red
		if anim_player and anim_player.has_animation("hurt"):
			anim_player.play("hurt")
	
func _on_hitbox_body_entered(body: Node3D) -> void:
	if body.is_in_group("Enemy") and body not in hit_entities:
		if body.has_node("HealthComponent"):
			var health_component = body.get_node("HealthComponent")
			if health_component and health_component.has_method("take_damage"):
				body.take_damage(attack_damage)
				hit_entities.append(body)  # Add to hit_entities to prevent multiple hits
