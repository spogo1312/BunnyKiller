extends Node2D

@export var speed: float = 150
@export var rotation_speed: float = 7.0
@export var damage: int = 10
var target: Node2D = null
var seeking: bool = false
@export var launch_duration: float = 0.1  # Time before bullet starts seeking a target
@export var lifetime: float = 5.0  # Time before the carrot despawns


@onready var timer = $Timer 
@onready var lifetime_timer = $LifetimeTimer # Add a timer for the lifetime

# Reference to the HitBox

func _ready() -> void:
	# Start the timer to switch from launching to seeking mode
	if has_node("Timer"):
		timer.start(launch_duration)
		timer.connect("timeout", Callable(self, "_on_Timer_timeout"))  # Connect the signal
		timer.start()
	if has_node("LifetimeTimer"):
		lifetime_timer.wait_time = lifetime
		lifetime_timer.connect("timeout", Callable(self, "_on_Lifetime_timeout"))
		lifetime_timer.start()
	seeking = false
	
	# Set up the HitBox

func _process(delta: float) -> void:
	if get_tree().get_nodes_in_group("enemies").size() == 0:
		queue_free()  # Despawn the carrot if no enemies are left
		return
	if not seeking:
		# Move the bullet straight up initially
		position.y -= speed * delta
	else:
		# Once in seeking mode, find the nearest target and home in on it
		if target and is_instance_valid(target):
			# Calculate the direction to the target
			var direction: Vector2 = (target.global_position - global_position).normalized()
			# Rotate towards the target
			rotation = lerp_angle(rotation, direction.angle(), rotation_speed * delta)
			# Move towards the target
			position += Vector2(cos(rotation), sin(rotation)) * speed * delta

	# Keep the HitBox following the bullet

func _on_Timer_timeout() -> void:
	# Switch to seeking mode after the timer ends
	seeking = true
	# Find the nearest enemy to target
	target = find_nearest_enemy()

func find_nearest_enemy() -> Node2D:
	var nearest_enemy: Node2D = null
	var shortest_distance: float = INF
	
	# Get a list of all enemies in the scene
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy):
			var distance: float = global_position.distance_to(enemy.global_position)
			if distance < shortest_distance:
				shortest_distance = distance
				nearest_enemy = enemy
	
	return nearest_enemy
func _on_Lifetime_timeout() -> void:
	# Despawn the carrot after its lifetime ends
	queue_free()
