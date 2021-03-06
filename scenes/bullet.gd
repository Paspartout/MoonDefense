extends KinematicBody2D

export(float) var speed
var velocity = Vector2(speed, 0)

const shoot_sounds = [preload("res://sfx/shoot_01.wav"), preload("res://sfx/shoot_02.wav")]

func _ready():
	rotation = velocity.angle()
	$AudioStreamPlayer.play()
	$AudioStreamPlayer.pitch_scale = rand_range(0.7, 1.2)

func _physics_process(delta):
	var hit = move_and_collide(velocity * delta)
	if hit:
		if hit.collider.has_method("hurt"):
			hit.collider.hurt()
		queue_free()

func shoot(direction: Vector2):
	velocity = direction.normalized() * speed

func on_screen_exited():
	queue_free()

func _on_LifeTimer_timeout():
	queue_free()

func hurt():
	queue_free()
