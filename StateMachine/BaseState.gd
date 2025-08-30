extends Node
class_name BaseState

var player: CharacterBody3D
var state_machine: StateMachine
var anim_player: AnimationPlayer

func enter() -> void:
	pass

func exit() -> void:
	pass

func physics_update(delta: float) -> void:
	pass

func get_blend_speed(current_speed: float) -> float:
	return 0.1 if current_speed > 0 else 0.3
