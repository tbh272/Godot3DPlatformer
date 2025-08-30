extends BaseState

var timer: float = 0.0

func enter() -> void:
	timer = randf_range(player.idle_time_min, player.idle_time_max)
	anim_player.play("Idle")
	player.velocity_target = Vector3.ZERO

func physics_update(delta: float) -> void:
	timer -= delta
	if player.target_player:
		state_machine.transition_to("Hesitate")
	elif timer <= 0.0:
		player._pick_new_direction()
		state_machine.transition_to("Wander")
