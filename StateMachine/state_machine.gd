extends Node

@export var initial_state: BaseState

var current_state: BaseState
var states: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is BaseState:
			states[child.name.to_lower()] = child
			child.state_machine = self
			child.player = get_parent()
			if child.player.has_node("Mesh/AnimationPlayer"):
				child.anim_player = child.player.get_node("Mesh/AnimationPlayer")
	if initial_state:
		transition_to(initial_state.name)


func transition_to(new_state_name: String) -> void:
	var new_state = states.get(new_state_name.to_lower())
	if new_state and new_state != current_state:
		if current_state:
			current_state.exit()
		current_state = new_state
		current_state.enter()
		##print("State changed to ", new_state_name)

func physics_update(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)
