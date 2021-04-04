tool
class_name Enemy
extends KinematicBody2D

signal died()

export var Bullet: PackedScene
export var Explosion: PackedScene

export var movement_speed: float = 100
export var accuracy: float = 30
export var starting_invul_sec: float = 1.0

onready var act_timer: Timer = $ActTimer
onready var shoot_timer: Timer = $ShootTimer
onready var sprite: Sprite = $Sprite
onready var invul_timer: Timer = $InvulTimer

enum FlightDirection {UP, DOWN}

var velocity: Vector2
var player: Player
var dead: bool = false
var invulnerable: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity = Vector2(0, 0)
	invul_timer.one_shot = true
	invul_timer.connect("timeout", self, "invul_timeout")
	make_invul(1.0)
	add_to_group("enemy")
	_start()

func make_invul(time: float):
	invulnerable = true
	sprite.material.set_shader_param("flash_white", true)
	invul_timer.wait_time = time
	invul_timer.start()

func invul_timeout():
	invulnerable = false
	sprite.material.set_shader_param("flash_white", false)

func _start():
	act_coro()
	shoot_coro()

func _physics_process(delta):
	var c = move_and_collide(velocity * delta)
	if c != null:
		if c.collider.collision_layer == 8:
			c.collider.queue_free()
			hurt()

func hurt():
	if not dead and not invulnerable:
		dead = true
		var e = Explosion.instance()
		e.position = self.position
		get_parent().add_child(e)
		emit_signal("died")
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
	pass

func shoot_coro():
	pass

func make_bullet():
	var b = Bullet.instance()
	b.position = position - Vector2(20, 0)
	return b

func shoot_left():
	var b = make_bullet()
	b.shoot(Vector2.LEFT)
	get_parent().add_child(b)

func shoot_at_player():
	var b = make_bullet()
	var player = get_tree().root.get_node("Main/Game").player
	if is_instance_valid(player):
		var random_offset = Vector2(rand_range(-accuracy, accuracy), rand_range(-accuracy, accuracy))
		b.shoot(b.position.direction_to(player.position + random_offset))
	else:
		b.shoot(Vector2.LEFT)

	if velocity.x < 0:
		b.velocity.x += velocity.x
	get_parent().add_child(b)

func move(direction: int, time: float):
	velocity.y = movement_speed if direction == FlightDirection.DOWN else -movement_speed
	yield(wait_act(time), "completed")
	velocity.y = 0

func shoot_burst(shots: int, delay: float, target=false):
	for i in range(shots):
		if target:
			shoot_at_player()
		else:
			shoot_left()
		yield(wait_shoot(delay), "completed")

func _on_LifeTimer_timeout():
	if position.x < 0:
		queue_free()
