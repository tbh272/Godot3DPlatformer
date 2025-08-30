extends BaseState

func enter() -> void:
	# Commented out as per user fix
	anim_player.play("Sword_Idle", -1, 1.0)
	pass

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
	if player.input_magnitude > 0:
		state_machine.transition_to("Walk")
		return
	## add more states here

	player.apply_movement(delta, 1.0, false)
	var current_speed = Vector2(player.velocity.x, player.velocity.z).length()
	if player.anim_player.current_animation != "Idle":
		player.anim_player.play("Idle", get_blend_speed(current_speed), 1.0)
	player.turn_to_direction(player.direction, delta)
