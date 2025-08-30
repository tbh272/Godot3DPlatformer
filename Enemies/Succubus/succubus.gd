extends CharacterBody3D

@export_group("Enemy Editable Variables")
@export var patrol_radius: float = 6.0  ## Radius for random patrol points
@export var patrol_speed: float = 3.0
@export var chase_speed: float = 4.5
@export var attack_range: float = 2.0
@export var attack_damage: float = 25.0
@export var attack_cooldown: float = 1.5  ## Seconds between attacks
@export var min_patrol_distance: float = 4.0  ## Minimum distance for new patrol points

@onready var state_machine: StateMachine = $StateMachine
@onready var detection_area: Area3D = $DetectionArea
@onready var hitbox: Area3D = $Mesh/Node/Sins/Body/Top/Arm_left/Forearm_left/Hand_left/ir_left_hand/Sins_Hoe/Hitbox
@onready var health_component: HealthComponent = $HealthComponent

var target: Node3D = null
var current_patrol_point: Vector3 = Vector3.ZERO
var attack_timer: float = 0.0

func _ready() -> void:
	detection_area.body_entered.connect(_on_body_entered_detection)
	detection_area.body_exited.connect(_on_body_exited_detection)
	hitbox.body_entered.connect(_on_body_entered_hitbox)
	floor_snap_length = 0.1
	up_direction = Vector3.UP
	current_patrol_point = get_random_patrol_point()
	#print("Initial patrol point: ", current_patrol_point)
	state_machine.transition_to("Patrol")

func _physics_process(delta: float) -> void:
	state_machine.physics_update(delta)
	if attack_timer > 0:
		attack_timer -= delta
	print("Current state: ", state_machine.current_state.name, " Position: ", global_position)

func take_damage(amount: float) -> void:
	health_component.health -= amount
	if health_component.health <= 0:
		queue_free()

func _on_body_entered_detection(body: Node3D) -> void:
	if body.is_in_group("Player"):
		target = body
		print("Player detected, transitioning to Chase")
		state_machine.transition_to("Chase")

func _on_body_exited_detection(body: Node3D) -> void:
	if body == target:
		target = null
		print("Player exited detection, transitioning to Patrol")
		state_machine.transition_to("Patrol")

func _on_body_entered_hitbox(body: Node3D) -> void:
	if body.is_in_group("Player") and attack_timer <= 0:
		if body.has_node("HealthComponent"):
			var health_component = body.get_node("HealthComponent")
			if health_component and health_component.has_method("take_damage"):
				body.take_damage(attack_damage)
				print("Player hit! Dealt damage: ", attack_damage)
				attack_timer = attack_cooldown

func get_random_patrol_point() -> Vector3:
	var attempts = 10
	while attempts > 0:
		var random_offset = Vector3(
			randf_range(-patrol_radius, patrol_radius),
			0,
			randf_range(-patrol_radius, patrol_radius)
		)
		var candidate_point = global_position + random_offset
		if (candidate_point - global_position).length() > min_patrol_distance:
			#print("Generated patrol point: ", candidate_point)
			return candidate_point
		attempts -= 1
	#print("Failed to find valid patrol point, using fallback")
	return global_position + Vector3(min_patrol_distance, 0, 0)
