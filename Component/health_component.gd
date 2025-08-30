extends Node
class_name HealthComponent

var health: int  # Starting health; adjust as needed
@export var max_health: int = 50  # Optional: For health bars or recovery
func _ready() -> void:
	health = max_health

func take_damage(amount: int) -> void:
	health -= amount
	health = clamp(health, 0, max_health)  # Prevent health from going below 0 or above max
	print("Enemy hit! Health now: ", health)  # For debugging; remove later
	
func die():
	if health <= 0:
		queue_free()
