extends BaseState

func enter() -> void:
	if anim_player and anim_player.has_animation("run"):
		anim_player.play("run")
	else:
		print("AnimationPlayer or 'run' animation missing!")

func physics_update(delta: float) -> void:
	if player.target:
		var target_position = player.target.global_position
		var direction = (target_position - player.global_position).normalized()
		var distance_to_target = player.global_position.distance_to(target_position)
		#print("Chasing target at: ", target_position, " Distance: ", distance_to_target, " Direction: ", direction)
		
		if distance_to_target <= player.attack_range and player.attack_timer <= 0:
			print("Within attack range, transitioning to Attack")
			state_machine.transition_to("Attack")
			return
		
		player.velocity = direction * player.chase_speed
		#print("Velocity: ", player.velocity)
		player.move_and_slide()
		
		# Rotate to face movement direction
		if direction.length() > 0:
			player.rotation.y = lerp_angle(player.rotation.y, atan2(direction.x, direction.z), delta * 5.0)
	else:
		player.velocity = Vector3.ZERO
		player.move_and_slide()
		if anim_player and anim_player.has_animation("idle"):
			anim_player.play("idle")
		print("No target, transitioning to Patrol")
		state_machine.transition_to("Patrol")
