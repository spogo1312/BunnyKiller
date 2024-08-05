extends Node2D

@export var player_scene = preload("res://Scenes/Player.tscn")
@export var slime_scene = preload("res://Scenes/slime.tscn")
@export var max_slimes = 4
@export var spawn_distance = 50 # Distance from the camera view
var player = null
var camera = null

func _ready():
	print("Spawning player...")
	# Spawn the player and add it to the scene
	spawn_player()

func spawn_player():
	player = player_scene.instantiate()
	add_child(player)
	player.global_position = Vector2(100, 100) # Set initial player position
	player.connect("spawned", Callable(self, "_on_Player_spawned"))

	# Assuming the camera is a child of the player
	camera = player.get_node("Camera2D")
	print("Player and camera initialized. Camera: ", camera)

	# Emit the spawned signal to trigger slime spawning
	player.emit_signal("spawned")

func _on_Player_spawned():
	print("Player spawned, clearing and spawning slimes...")
	# Clear existing slimes if needed
	clear_existing_slimes()

	# Spawn slimes randomly on the left or right side of the camera view
	for i in range(max_slimes):
		spawn_slime()
	print("Finished spawning slimes")

func clear_existing_slimes():
	print("Clearing existing slimes...")
	# Remove existing slimes if necessary
	for slime in get_tree().get_nodes_in_group("slimes"):
		slime.queue_free()
	print("Existing slimes cleared")

func spawn_slime():
	print("Spawning a new slime...")
	var slime = slime_scene.instantiate()
	add_child(slime)
	slime.set_player(player) # Pass the player reference to the slime

	# Get the camera position and size
	var camera_pos = camera.global_position
	var screen_size = get_viewport().size

	# Determine spawn position (left or right of the camera view)
	var spawn_pos = Vector2()
	if randf() > 0.5:
		# Spawn on the right side
		spawn_pos.x = camera_pos.x + screen_size.x / 2 + spawn_distance
	else:
		# Spawn on the left side
		spawn_pos.x = camera_pos.x - screen_size.x / 2 - spawn_distance

	# Randomize the y position within the camera's view
	spawn_pos.y = camera_pos.y + randf_range(-screen_size.y / 2, screen_size.y / 2)

	# Set the slime's position
	slime.global_position = spawn_pos

	# Debug print to check slime position
	print("Spawned slime at position: ", spawn_pos)

	# Optional: Add a debug visual for slime position
	var debug_marker = ColorRect.new()
	debug_marker.color = Color(1, 0, 0, 0.5) # Semi-transparent red
	debug_marker.size = Vector2(10, 10) # Small square
	debug_marker.position = spawn_pos - debug_marker.size / 2
	add_child(debug_marker)
	print("Debug marker added at position: ", debug_marker.position)
