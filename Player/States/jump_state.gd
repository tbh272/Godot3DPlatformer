extends BaseState

func enter() -> void:
	player.velocity.y = player.jump_velocity
	#player.is_jumping = true
	player.jump_buffer_timer = 0
	player.coyote_timer = 0
	var tween = player.create_tween()
	tween.tween_property(player.mesh, "scale", Vector3(1.2, 0.8, 1.2), 0.1)
	tween.tween_property(player.mesh, "scale", Vector3(1.0, 1.0, 1.0), 0.1)
	print("Jump initiated")
	player.anim_player.play("Jump_Start", -1, 1.0)

func physics_update(delta: float) -> void:
	if player.velocity.y <= 0 and not player.is_on_floor():
		state_machine.transition_to("Fall")
		return

	if Input.is_action_pressed("jump") and player.jump_held_time < player.jump_hold_time:
		player.jump_held_time += delta
	if Input.is_action_just_released("jump") or player.jump_held_time >= player.jump_hold_time:
		#player.is_jumping = false
		player.jump_held_time = 0

	player.apply_movement(delta, 1.0, false)
	var current_speed = Vector2(player.velocity.x, player.velocity.z).length()
	player.turn_to_direction(player.direction, delta)
	# Animation set in enter, assume it plays during ascent
