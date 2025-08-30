extends BaseState

func enter() -> void:
	player.hit_entities.clear()
	player.hitbox.monitoring = true
	anim_player.play("Sword_Attack", 0.3, 1.3) #change to attack animation

func exit() -> void:
	player.hitbox.monitoring = false
	pass

func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		state_machine.transition_to("Fall")
		return

	player.apply_movement(delta, 0.5, false)
	var current_speed = Vector2(player.velocity.x, player.velocity.z).length()
	player.turn_to_direction(player.direction, delta)
	# Animation set in enter, transitions on finished
