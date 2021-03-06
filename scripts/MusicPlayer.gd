extends AudioStreamPlayer

const song_remaining = preload("res://mus/song_remaining.ogg")

export var tutorial_path: NodePath
var play_remaining_song = true

func _ready():
	connect("finished", self, "next_song")

func tutorial_done():
	play_remaining_song = true

func next_song():
	if play_remaining_song:
		stream = song_remaining
		play()
	else:
		play(1.55)
