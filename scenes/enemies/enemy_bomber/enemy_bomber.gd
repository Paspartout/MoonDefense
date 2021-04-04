class_name EnemyBomber
extends Enemy

enum FlightDirection {UP, DOWN}
export(FlightDirection) var direction = FlightDirection.UP

func _ready():
	print("Easy here")

func move(direction: int, time: float):
	velocity.y = movement_speed if direction == FlightDirection.DOWN else -movement_speed
	yield(wait_act(time), "completed")
	velocity.y = 0

func shoot_burst(shots: int, delay: float):
	for i in range(shots):		
		shoot_left()
		yield(wait_shoot(delay), "completed")

func act_coro():
	velocity = Vector2.LEFT * movement_speed
	yield(wait_act(1), "completed")
	velocity.x = 0
	var opposite_direction = FlightDirection.UP if direction == FlightDirection.DOWN else FlightDirection.DOWN
	while true:
		for i in range(5):
			yield(move(direction, 0.25), "completed")
			yield(shoot_burst(3, 0.15), "completed")
			yield(wait_act(0.25), "completed")
			
		for i in range(5):
			yield(move(opposite_direction, 0.25), "completed")
			yield(shoot_burst(3, 0.15), "completed")
			yield(wait_act(0.25), "completed")
