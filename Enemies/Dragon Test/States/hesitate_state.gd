extends BaseState

var timer: float = 0.0

func enter() -> void:
	timer = player.attack_hesitation_time
	anim_player.play("Idle")

func physics_update(delta: float) -> void:
	timer -= delta
	if not player.target_player:
		state_machine.transition_to("Idle")
	elif timer <= 0.0:
		state_machine.transition_to("Attack")
