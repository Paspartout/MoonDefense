class_name Asteroid
extends KinematicBody2D

const Explosion = preload("res://scenes/explosion.tscn")

export var speed: float = 60
onready var velocity: Vector2 = Vector2.LEFT * speed
var already_entered = false
onready var rand_rotation = rand_range(-0.3, 0.3)

func _physics_process(delta):
	var c = move_and_collide(velocity * delta)
	if c != null:
		if c.collider.collision_layer == 8:
			c.collider.queue_free()
			hurt()
		else:
			hurt()
	rotate(rand_rotation * delta)

func hurt():
	var e = Explosion.instance()
	e.position = self.position
	get_parent().add_child(e)
	queue_free()

func _on_LifeTimer_timeout():
	if position.x < 0:
		queue_free()
