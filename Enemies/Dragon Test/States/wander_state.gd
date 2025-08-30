extends BaseState

func enter() -> void:
	player.anim_player.play("Move")
	# Pick an initial wander direction
	player._pick_new_direction()

func physics_update(delta: float) -> void:
	# --- Wall avoidance ---
	if player.wall_blocked:
		# Smoothly turn away from wall
		player.rotation.y += player.turn_speed * delta
		# Pick a new wander direction after turning
		player._pick_new_direction()

	# --- Forward movement ---
	var dir = player.wander_direction
	player.velocity_target = dir * player.speed
	player._rotate_toward(dir, delta)

	# --- Check if too far from home ---
	if (player.global_position - player.home_position).length() > player.wander_radius:
		player._pick_new_direction()

	# --- Transition to player detection ---
	if player.target_player:
		state_machine.transition_to("Hesitate")
