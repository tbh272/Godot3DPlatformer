extends BaseState

func enter() -> void:
	player.is_attacking = false

func physics_update(delta: float) -> void:
	if not player.target_player:
		state_machine.transition_to("Idle")
		return

	var dist = player.global_position.distance_to(player.target_player.global_position)
	var dir = (player.target_player.global_position - player.global_position).normalized()

	# move toward player if out of attack range
	if dist > player.ground_attack_distance:
		player.velocity_target = dir * player.speed
		player._rotate_toward(dir, delta)
	else:
		player.velocity_target = Vector3.ZERO

	# attack if in range & cooldown ready
	if not player.is_attacking and player.attack_cooldown_timer <= 0.0 and dist <= player.ground_attack_distance:
		var attacks = ["attack_2", "attack_3", "attack_4"]
		player.anim_player.play(attacks[randi() % attacks.size()])
		player.is_attacking = true
		player.attack_cooldown_timer = player.attack_cooldown
