extends BaseState

@export var idle_time_min: float = 1.0
@export var idle_time_max: float = 3.0

var idle_timer: float = 0.0

func enter() -> void:
	idle_timer = randf_range(idle_time_min, idle_time_max)
	anim_player.play("idle")

func physics_update(delta: float) -> void:
	idle_timer -= delta

	# If player detected, switch to approach
	if player.player_in_range:
		state_machine.transition_to("Approach")
		return

	# When idle ends, go wander
	if idle_timer <= 0.0:
		state_machine.transition_to("Wander")
