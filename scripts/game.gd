class_name Game
extends Node2D

onready var tween: Tween = $Tween

export var hud_path: NodePath
export var msg_box_path: NodePath
export var tutorial_path: NodePath
export var game_timer_path: NodePath
export var player_path: NodePath
export var flying_area_path: NodePath
export var ground_level_path: NodePath
export var kill_area_path: NodePath
export var pause_menu_path: NodePath

onready var msg_box: AnimationPlayer = get_node(msg_box_path).get_node("AnimationPlayer")
onready var hud = get_node(hud_path)
onready var tutorial: Tutorial = get_node(tutorial_path)
onready var game_timer = get_node(game_timer_path)
onready var flying_area: Node2D = get_node(flying_area_path)
onready var flying_section: Node2D = get_node(flying_area_path).get_node("FlyingSection")
onready var ground_level: Node2D = get_node(ground_level_path)
onready var kill_area: Area2D = get_node(kill_area_path)
onready var pause_menu: Node2D = get_node(pause_menu_path)

export var current_section: int = 0
export var skip_tutorial: bool = false
export var transition_delay: float = 3.0
export var debug_enabled = false

var current_movement_speed = 100
var disable_menu: bool = false

export(Array, PackedScene) var sections
onready var n_sections = sections.size()

const PlayerScene = preload("res://scenes/player.tscn")
var player: Player

func _ready():
	kill_area.connect("body_entered", self, "killarea_entered")

func _get_configuration_warning():
	if hud_path.is_empty() or tutorial_path.is_empty():
		return "hud or tutorial path not set!"
	return ""

var old_speed: float = 100

func _input(event):
	if event.is_action_pressed("stop"):
		old_speed = flying_area.movement_speed
		tween.interpolate_property(flying_area, "movement_speed",
				null, 25, 0.2,
				Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		tween.start()
	if event.is_action_released("stop"):
		flying_area.movement_speed = old_speed
		tween.interpolate_property(flying_area, "movement_speed",
				null, old_speed, 0.2,
				Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		tween.start()
	if event.is_action_pressed("pause") and not disable_menu:
		flying_area.movement_speed = old_speed
		pause_menu.pause()
	if event.is_action_pressed("screenshot"):
		var image = get_viewport().get_texture().get_data()
		image.flip_y()
		image.save_png("screenshot.png")

	if debug_enabled:
		if Input.is_action_just_pressed("debug_hurt"):
			if is_instance_valid(player):
				player.hurt()
		if Input.is_action_just_pressed("debug_killall"):
			var enemies = get_tree().get_nodes_in_group("enemy")
			for enemy in enemies:
				enemy.hurt()
		if Input.is_action_just_pressed("debug_timer"):
			game_timer.visible = !game_timer.visible
		if Input.is_action_just_pressed("debug_speedup"):
			old_speed = flying_area.movement_speed
			flying_area.movement_speed = 200
		if Input.is_action_just_released("debug_speedup"):
			flying_area.movement_speed = old_speed

func start():
	hud.visible = true
	player = setup_player(get_node(player_path))
	player.controllable = true
	if skip_tutorial:
		tutorial_done()
		tutorial.queue_free()
	else:
		tutorial.start()
		tutorial.connect("done", self, "tutorial_done")

func setup_player(p: Player):
	hud.set_player(p)
	p.connect("died", self, "death")
	return p

func spawn_player():
	if is_instance_valid(player):
		push_warning("old player still valid!")
		# player.disconnect("died", self, "death")
	player = setup_player(PlayerScene.instance())
	player.position = Vector2(-100, 100)
	flying_area.add_child(player)

func death():
	call_deferred("respawn_player")

func respawn_player():
	disable_menu = true
	kill_area.monitoring = false
	for e in get_tree().get_nodes_in_group("enemy"):
		e.kill()
	var lpf: AudioEffectLowPassFilter = AudioServer.get_bus_effect(1, 0)
	AudioServer.set_bus_effect_enabled(1, 0, true)
	tween.interpolate_property(lpf, "cutoff_hz", 20500, 100, 1,
		Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	# Reverse parralax movement
	tween.interpolate_property(flying_area, "movement_speed",
			200, -1000, 1,
			Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.interpolate_property(flying_section, "position",
		flying_section.position, flying_section.position + Vector2(700, 0), 1,
		Tween.TRANS_QUAD, Tween.EASE_IN, 0.5)
	tween.interpolate_property(flying_section, "modulate",
		Color(1,1,1,1), Color(1,1,1,0), 1,
		Tween.TRANS_QUAD, Tween.EASE_IN_OUT, 0.5)
	tween.interpolate_property(ground_level, "modulate",
		Color(1,1,1,1), Color(1,1,1,0), 1,
		Tween.TRANS_QUAD, Tween.EASE_IN_OUT, 0.5)
	tween.start()

	yield(tween, "tween_all_completed")
	for c in flying_section.get_children():
		c.queue_free()
	for c in ground_level.get_children():
		c.queue_free()
	flying_section.modulate = Color(1,1,1,1)
	ground_level.modulate = Color(1,1,1,1)

	# Back To normal speed
	spawn_player()
	tween.interpolate_property(flying_area, "movement_speed",
			-1000, current_movement_speed, 1,
			Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.interpolate_property(lpf, "cutoff_hz", 100, 20500, 1,
	Tween.TRANS_QUAD, Tween.EASE_IN_OUT)

	tween.interpolate_property(player, "position",
		Vector2(-50, 140), Vector2(100, 140), 1,
		Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()

	yield(tween, "tween_all_completed")
	AudioServer.set_bus_effect_enabled(1, 0, false)

	flying_section.position = Vector2(0, 0)
	load_section(false)
	kill_area.monitoring = true
	disable_menu = false

func transition_flying(transition_time: float = 1.5):
	var old_pos = flying_area.position

	# Fly up
	tween.interpolate_property(flying_area, "position",
			old_pos, Vector2(old_pos.x, 0), transition_time,
			Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	# Accelerate
	tween.interpolate_property(flying_area, "movement_speed",
			0, current_movement_speed, transition_time,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_all_completed")

func transition_ground(transition_time: float = 1):
	# Deccelerate
	tween.interpolate_property(flying_area, "movement_speed",
			200, 0, transition_time,
			Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	# Fly down
	var old_pos = flying_area.position
	tween.interpolate_property(flying_area, "position",
			old_pos, Vector2(old_pos.x, 64), transition_time,
			Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	# Accelerate
	tween.interpolate_property(flying_area, "movement_speed",
			0, current_movement_speed, transition_time,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	

func tutorial_done():
	# Start Player/World Movement
	$MusicPlayer.play()
	disable_menu = true
	yield(transition_flying(), "completed")
	disable_menu = false

	yield(get_tree().create_timer(3.0), "timeout")
	for c in ground_level.get_children():
		c.queue_free()
	load_section()

func load_section(transition=true):
	var next_section = sections[current_section].instance()
	next_section.connect("cleared", self, "next_section")
	current_movement_speed = next_section.movement_speed
	if next_section.is_ground_section:
		if transition:
			disable_menu = true
			yield(transition_ground(), "completed")
			disable_menu = false
		next_section.position.x = flying_area.position.x + 600
		next_section.position.y = 65
		ground_level.add_child(next_section)
	else:
		flying_section.add_child(next_section)

func next_section():
	msg_box.play("Success")
	player.make_invul(3.0)

	current_section += 1
	yield(get_tree().create_timer(transition_delay), "timeout")

	if current_section >= n_sections:
		player.controllable = false
		player.collision_layer = 0
		tween.interpolate_property(player, "position",
			null, Vector2(100, 140), 0.5,
			Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		tween.interpolate_property($MusicPlayer, "volume_db",
			null, -20, 0.5,
			Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		tween.start()
		yield(tween, "tween_all_completed")
		tween.interpolate_property(player, "position",
			null, Vector2(1000, 140), 2,
			Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		tween.interpolate_property(flying_area, "movement_speed",
			null, 1000, 1,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		yield(tween, "tween_all_completed")

		msg_box.play("Winning")
		yield(msg_box, "animation_finished")
		get_tree().reload_current_scene()
		return

	load_section()

func killarea_entered(_body):
	kill_area.set_deferred("monitoring", false)
	player.kill()

