extends BaseState

func enter() -> void:
	player.anim_player.play("Jump_Land", 1.5, 1.2)
	print("Entered LANDING state")

func physics_update(delta: float) -> void:
	## For roll, perhaps no movement or decelerate
	player.apply_movement(delta, 1.0, false)  # Stop movement
	var current_speed = Vector2(player.velocity.x, player.velocity.z).length()
	player.turn_to_direction(player.direction, delta)
