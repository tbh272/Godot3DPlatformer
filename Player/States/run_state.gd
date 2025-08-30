extends BaseState

func enter() -> void:
	pass

func physics_update(delta: float) -> void:
	# Similar to Walk, but assume sprint logic if added later
	# For now, mirror Walk
	if not player.is_on_floor():
		state_machine.transition_to("Fall")
		return
	# Add transitions similar to Walk...

	player.apply_standard_movement(delta)
	var current_speed = Vector2(player.velocity.x, player.velocity.z).length()
	var blend_speed = get_blend_speed(current_speed)
	if player.anim_player.current_animation != "freehand_run":
		player.anim_player.play("freehand_run", blend_speed, 1.0)
	player.turn(player.direction, delta)
