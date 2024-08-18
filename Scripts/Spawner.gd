extends Node2D

@export var player_scene = preload("res://Scenes/Player.tscn")
@export var slime_scene = preload("res://Scenes/slime.tscn")
@export var carrot_scene = preload("res://Scenes/baby_carrot.tscn")
@export var max_slimes = 4
@export var spawn_distance = 50 # Distance from the camera view
@export var carrot_shoot_interval = 1.5 # Time interval between carrot shots
@export var max_carrots = 2  # Maximum number of carrots allowed


var player = null
var camera = null
var current_carrot_count = 0  # Track the number of active carrots


func _ready():
	print("Spawning player...")
	# Spawn the player and add it to the scene
	spawn_player()

	# Setup the Timer for shooting carrots
	var carrot_timer = Timer.new()
	carrot_timer.wait_time = carrot_shoot_interval
	carrot_timer.autostart = true
	carrot_timer.connect("timeout", Callable(self, "_on_CarrotCheck_timeout"))
	add_child(carrot_timer)

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

# Function to handle carrot shooting
# Function to handle carrot shooting
func _on_CarrotCheck_timeout():
	# Check if any enemy is on-screen
	if is_enemy_visible() and current_carrot_count < max_carrots and player:
		shoot_carrot()

# Function to check if any enemy is visible on the screen
func is_enemy_visible() -> bool:
	# Convert the screen size (Vector2i) to Vector2 for proper subtraction
	var screen_size = get_viewport().size
	var screen_size_v2 = Vector2(screen_size.x, screen_size.y)  # Convert to Vector2

	# Calculate the screen rectangle
	var screen_rect = Rect2(camera.global_position - screen_size_v2 / 2, screen_size_v2)
	
	# Check all enemies in the scene
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if screen_rect.has_point(enemy.global_position):
			return true  # At least one enemy is visible
	return false  # No enemies are visible


func shoot_carrot():
	var carrot = carrot_scene.instantiate()
	carrot.global_position = player.global_position  # Start from the player's position
	carrot.connect("tree_exited", Callable(self, "_on_Carrot_despawned"))  # Track when a carrot despawns
	add_child(carrot)
	current_carrot_count += 1  # Increment the active carrot count

# Function called when a carrot despawns
func _on_Carrot_despawned():
	current_carrot_count -= 1  # Decrement the active carrot count
