class_name Player
extends KinematicBody2D

export var controllable = true

var input_vec: Vector2
var velocity: Vector2
var sprite: AnimatedSprite
var max_speed = 100
var health = 5
var invulnerable = false

signal hp_changed(new_hp)
signal died()

const ACCEL = 30
const DRAG = 0.7

const SPEED = 350
const BOOST_SPEED = 500
const SHOOT_SPEED = 75

const Bullet = preload("res://scenes/bullets/player_bullet.tscn")
const Explosion = preload("res://scenes/explosion.tscn")

# Called when t1he node enters the scene tree for the first time.
func _ready():
	velocity = Vector2.ZERO
	sprite = get_node("AnimatedSprite")
	print(get_path())
	emit_signal("hp_changed", health)

func _input(_event):
	if not controllable:
		return
	input_vec = Vector2.ZERO
	input_vec.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vec.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	if Input.is_action_pressed("boost"):
		max_speed = BOOST_SPEED
	elif Input.is_action_pressed("shoot"):
		max_speed = SHOOT_SPEED
	else:
		max_speed = SPEED

	if Input.is_action_just_pressed("shoot"):
		on_shoot()
		$ShootTimer.start()
	elif Input.is_action_just_released("shoot"):
		$ShootTimer.stop()

func _physics_process(delta):
	if controllable:
		if input_vec != Vector2.ZERO:
			velocity += input_vec * ACCEL
			velocity = velocity.clamped(max_speed)
		else:
			velocity *= DRAG
			if velocity.length_squared() <= 1.0:
				velocity = Vector2.ZERO

		if input_vec.y > 0:
			sprite.frame = 1
		elif input_vec.y < 0:
			sprite.frame = 2
		else:
			sprite.frame = 0

	var c = move_and_collide(velocity * delta)
	if c != null:
		if c.collider.collision_layer == 16:
			c.collider.queue_free()
			hurt()
		elif c.collider.collision_layer == 4:
			c.collider.hurt()
			hurt()

func on_shoot():
	var b = Bullet.instance()
	b.shoot(Vector2.RIGHT)
	# TODO: This could probably be moved into shoot
	if velocity.x > 0:
		b.velocity.x += velocity.x
	b.position = position + Vector2(30, 0)
	get_parent().add_child(b)

func make_invul(time: float):
	invulnerable = true
	$AnimatedSprite.material.set_shader_param("flash_white", true)
	$InvulTimer.wait_time = time
	$InvulTimer.start()
		
func on_invul_over():
	invulnerable = false
	$AnimatedSprite.material.set_shader_param("flash_white", false)

func hurt():
	if invulnerable or health <= 0:
		return
	health = max(health-1, 0)
	emit_signal("hp_changed", health)
	if health <= 0:
		kill()
	else:
		make_invul(1.0)
		$AudioStreamPlayer.stream = preload("res://sfx/hurt_01.wav")
		$AudioStreamPlayer.play()

func kill():
	var e = Explosion.instance()
	e.position = self.position
	get_parent().add_child(e)
	queue_free()
	emit_signal("died")

