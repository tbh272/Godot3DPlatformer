extends BaseState

func enter() -> void:
	player.target = null
	if anim_player and anim_player.has_animation("walk"):
		anim_player.play("walk")
	else:
		print("AnimationPlayer or 'walk' animation missing!")

func physics_update(delta: float) -> void:
	if not player.target:
		var direction = (player.current_patrol_point - player.global_position).normalized()
		var distance = player.global_position.distance_to(player.current_patrol_point)
		#print("Patrol target: ", player.current_patrol_point, " Distance: ", distance, " Direction: ", direction)
		
		if distance < 0.5:  # Threshold to consider point reached
			#print("Reached patrol point")
			player.current_patrol_point = player.get_random_patrol_point()
			#print("New random patrol point: ", player.current_patrol_point)
		
		player.velocity = direction * player.patrol_speed
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
		print("Target detected or no valid patrol point")

	if player.target:
		print("Target detected, transitioning to Chase")
		state_machine.transition_to("Chase")
