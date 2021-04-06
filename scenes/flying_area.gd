extends Node2D

export var movement_speed: float = 0
	
func _process(delta):
	position.x += movement_speed * delta

