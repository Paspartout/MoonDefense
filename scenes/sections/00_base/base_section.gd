extends Section

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func player_exited_cave(_body):
	emit_signal("cleared")
