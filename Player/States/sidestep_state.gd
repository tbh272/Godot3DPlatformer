extends BaseState

func enter() -> void:
	player.start_dodge(player.direction, true)
	##player.anim_player.play("sidestep", 0.05, 1.0)

func physics_update(delta: float) -> void:
	player.dodge_timer -= delta
	if player.dodge_timer <= 0:
		state_machine.transition_to("Block")
		return

	player.apply_movement(delta, 2.0, false)
	var current_speed = Vector2(player.velocity.x, player.velocity.z).length()
	player.turn_to_direction(player.get_mouse_world_direction(), delta)
