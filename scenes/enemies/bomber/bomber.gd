class_name EnemyBomber
extends Enemy

export(FlightDirection) var direction = FlightDirection.UP
export var hops: int = 5

func act_coro():
	velocity = Vector2.LEFT * movement_speed
	yield(wait_act(1), "completed")
	velocity.x = 0
	var opposite_direction = FlightDirection.UP if direction == FlightDirection.DOWN else FlightDirection.DOWN
	while true:
		for i in range(hops):
			yield(move(direction, 0.25), "completed")
			yield(shoot_burst(3, 0.15), "completed")
			yield(wait_act(0.25), "completed")
			
		for i in range(hops):
			yield(move(opposite_direction, 0.25), "completed")
			yield(shoot_burst(3, 0.15), "completed")
			yield(wait_act(0.25), "completed")
