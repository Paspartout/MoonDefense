extends Section

onready var asteroids = $Asteroids

func _ready():
	var timer = Timer.new()
	timer.autostart = true
	add_child(timer)
	timer.connect("timeout", self, "asteroids_changed")

func asteroids_changed():
	if asteroids.get_child_count() <= 0:
		print("Asteroids cleared!")
		emit_signal("cleared")
		queue_free()
