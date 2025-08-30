extends BaseState

func enter() -> void:
	pass  # Animation handled in physics_update

func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		state_machine.transition_to("Fall")
		return
	if Input.is_action_just_pressed("attack"):
		state_machine.transition_to("Attack")
		return
	if Input.is_action_pressed("block"):
		state_machine.transition_to("Block")
		return
	if Input.is_action_just_pressed("dodge"):
		state_machine.transition_to("Dodge")
		return
	if player.jump_buffer_timer > 0 and player.coyote_timer > 0:
		state_machine.transition_to("Jump")
		return
	if player.input_magnitude == 0:
		state_machine.transition_to("Idle")
		return

	player.apply_movement(delta, 1.0, false)
	var current_speed = Vector2(player.velocity.x, player.velocity.z).length()
	var blend_speed = get_blend_speed(current_speed)
	if player.anim_player.current_animation != "Running_B":
		player.anim_player.play("Sprint", blend_speed, 1.0)
	player.anim_player.speed_scale = lerp(0.5, 1.75, current_speed / player.run_speed)
	player.turn_to_direction(player.direction, delta)
