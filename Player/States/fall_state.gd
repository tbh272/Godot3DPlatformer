extends BaseState

func enter() -> void:
	pass

func physics_update(delta: float) -> void:
	player.apply_movement(delta, 1.0, false)
	
	var current_speed = Vector2(player.velocity.x, player.velocity.z).length()
	var blend_speed = get_blend_speed(current_speed)
	
	if player.anim_player.current_animation != "Jump_Idle": ## <-- this animation is redundant
		player.anim_player.play("Jump", blend_speed, 1.0)
		player.turn_to_direction(player.direction, delta)
	
	if player.is_on_floor():
		state_machine.transition_to("Land")
