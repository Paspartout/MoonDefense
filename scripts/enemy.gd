class_name Enemy
extends KinematicBody2D

export var shoot_delay: float = 0.75
export var randomize_act_delay: bool = false
export var act_delay: float = 0.75
export var movement_speed: float = 100
export var accuracy: float = 30

export var player_path: NodePath

onready var act_timer: Timer = $ActTimer
onready var shoot_timer: Timer = $ShootTimer

var velocity

const Bullet = preload("res://scenes/bullet.tscn")
const Explosion = preload("res://scenes/explosion.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity = Vector2(0, 0)
	if randomize_act_delay:
		act_delay = rand_range(1, 2)
	act_timer.wait_time = act_delay
	act_coro()
	shoot_coro()
	print("HI")

func _physics_process(delta):
	var c = move_and_collide(velocity * delta)
	if c != null:
		if c.collider.collision_layer == 8:
			c.collider.queue_free()
			hurt()

func hurt():
	var e = Explosion.instance()
	e.position = self.position
	get_parent().add_child(e)
	queue_free()

func wait_act(time: float):
		act_timer.wait_time = time
		act_timer.start()
		yield(act_timer, "timeout")

func wait_shoot(time: float):
		shoot_timer.wait_time = time
		shoot_timer.start()
		yield(shoot_timer, "timeout")

func act_coro():
	velocity = Vector2.LEFT * movement_speed
	while true:
		velocity.y = movement_speed
		yield(wait_act(1), "completed")
		velocity.y = -movement_speed
		yield(wait_act(1), "completed")

func shoot_coro():
	yield(wait_shoot(0.1), "completed")
	while true:
		shoot_left()
		yield(wait_shoot(0.1), "completed")
		shoot_left()
		yield(wait_shoot(0.1), "completed")
		shoot_left()
		yield(wait_shoot(1.0), "completed")

func shoot_left():
	var b = Bullet.instance()
	b.position = position - Vector2(20, 0)
	b.shoot(Vector2.LEFT)
	get_parent().add_child(b)

func shoot_at_player():
	var b = Bullet.instance()
	b.position = position - Vector2(20, 0)
	if has_node(player_path):
		var target = get_node(player_path)
		var random_offset = Vector2(rand_range(-accuracy, accuracy), rand_range(-accuracy, accuracy))
		b.shoot(b.position.direction_to(target.position + random_offset))
	else:
		b.shoot(Vector2.LEFT)
	if velocity.x < 0:
		b.velocity.x += velocity.x
	get_parent().add_child(b)


func _on_LifeTimer_timeout():
	if position.x < 0:
		queue_free()
