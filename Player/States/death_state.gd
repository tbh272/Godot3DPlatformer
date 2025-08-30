extends BaseState

func enter() -> void:
	# Stop movement
	player.velocity = Vector3.ZERO
	# Disable physics processing to prevent further movement
	player.set_physics_process(false)
	# Play death animation if available
	if anim_player and anim_player.has_animation("Death01"):
		anim_player.play("Death01")
		# Optionally connect to animation finished signal
		if not anim_player.is_connected("animation_finished", _on_animation_finished):
			anim_player.animation_finished.connect(_on_animation_finished)
	else:
		# If no animation, trigger game over immediately
		_on_animation_finished("")

func exit() -> void:
	# Re-enable physics processing if exiting death state (e.g., for respawn)
	player.set_physics_process(true)
	if anim_player and anim_player.is_connected("animation_finished", _on_animation_finished):
		anim_player.animation_finished.disconnect(_on_animation_finished)

func physics_update(delta: float) -> void:
	# No physics updates in death state
	pass

func _on_animation_finished(_anim_name: String) -> void:
	# Trigger game over logic (e.g., show game over screen, reload scene)
	print("Player death animation finished. Triggering game over.")
	# Example: Reload current scene (replace with your game over logic)
	get_tree().reload_current_scene()
