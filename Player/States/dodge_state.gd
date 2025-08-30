extends BaseState

func enter() -> void:
	player.start_dodge(player.direction)
	player.anim_player.play("Roll", 0.1, 1.0)

func physics_update(delta: float) -> void:
	player.dodge_timer -= delta
	if player.dodge_timer <= 0:
		state_machine.transition_to("Idle" if player.input_magnitude == 0 else "Walk")
		return

	player.apply_dodge_movement(delta)
	var current_speed = Vector2(player.velocity.x, player.velocity.z).length()
	player.turn_to_direction(player.direction, delta)
