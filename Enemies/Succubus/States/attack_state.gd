extends BaseState

func enter() -> void:
	if anim_player and anim_player.has_animation("attack"):
		anim_player.play("attack")
	else:
		print("AnimationPlayer or 'attack' animation missing!")
	player.velocity = Vector3.ZERO
	player.move_and_slide()
	print("Entered Attack state")

func physics_update(delta: float) -> void:
	player.velocity = Vector3.ZERO
	player.move_and_slide()  # Ensure no movement during attack
	if player.target:
		var distance_to_target = player.global_position.distance_to(player.target.global_position)
		#print("Attack state: Distance to target: ", distance_to_target, " Attack timer: ", player.attack_timer)
		if distance_to_target > player.attack_range or player.attack_timer > 0:
			#print("Target out of range or attack on cooldown, transitioning to Chase")
			state_machine.transition_to("Chase")
	else:
		print("No target, transitioning to Patrol")
		state_machine.transition_to("Patrol")
