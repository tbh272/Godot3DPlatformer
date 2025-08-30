extends BaseState

func enter() -> void:
	player.anim_player.play("Block", 0.1, 1.0)

func physics_update(delta: float) -> void:
	if not Input.is_action_pressed("block"):
		state_machine.transition_to("Idle")
		return
	if Input.is_action_just_pressed("dodge"):
		state_machine.transition_to("Sidestep")
		return

	player.apply_movement(delta, 1.0, true)
	var current_speed = Vector2(player.velocity.x, player.velocity.z).length()
	if player.anim_player.current_animation != "Block":
		player.anim_player.play("Blocking", 0.1, 1.0)
	player.turn_to_direction(player.get_mouse_world_direction(), delta)
