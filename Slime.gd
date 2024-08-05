extends CharacterBody2D

@export var gravity = 400
@export var jump_force = -100

@onready var jump_timer = $Timer
@onready var animated_sprite = $AnimatedSprite2D

var player = null
var is_jumping = false
var is_landing = false
var jump_direction = Vector2.ZERO
var speed = 0.0

func _ready():
	speed = randf_range(30.0, 40.0)
	jump_timer.timeout.connect(_on_jump_timer_timeout)
	animated_sprite.animation_finished.connect(_on_animation_finished)
	animated_sprite.play("Idle")
	jump_timer.start(2)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
		# Apply horizontal movement only when in the air
		velocity.x = jump_direction.x * speed
	else:
		# Stop horizontal movement when on the ground
		velocity.x = 0

	move_and_slide()

	if is_jumping:
		update_jump_animation()
	elif is_on_floor() and not is_landing:
		animated_sprite.play("Idle")

func _on_jump_timer_timeout():
	if is_on_floor() and not is_jumping and not is_landing and player:
		animated_sprite.play("JumpStart")
		
		# Calculate jump direction towards the player
		jump_direction = (player.global_position - global_position).normalized()
		
		velocity.y = jump_force
		velocity.x = jump_direction.x * speed
		is_jumping = true
		animated_sprite.play("JumpUp")
		
		# Flip sprite based on jump direction
		animated_sprite.flip_h = jump_direction.x < 0

func _on_animation_finished():
	match animated_sprite.animation:
		"Land":
			is_landing = false
			animated_sprite.play("Idle")
			jump_timer.start(2)
		"JumpUp":
			if is_jumping:
				animated_sprite.play("JumpArc")
		"JumpArc":
			if is_jumping:
				animated_sprite.play("JumpDown")
		"JumpDown":
			if is_on_floor():
				is_jumping = false
				is_landing = true
				animated_sprite.play("Land")

func set_player(p):
	player = p

func update_jump_animation():
	if not is_on_floor():
		if velocity.y < -20:
			animated_sprite.play("JumpUp")
		elif abs(velocity.y) <= 20:
			animated_sprite.play("JumpArc")
		elif velocity.y > 20:
			animated_sprite.play("JumpDown")
	else:
		is_jumping = false
		is_landing = true
		animated_sprite.play("Land")

# Debug function to print current state
func _print_debug_info():
	print("Velocity: ", velocity)
	print("Is on floor: ", is_on_floor())
	print("Is jumping: ", is_jumping)
	print("Is landing: ", is_landing)
	print("Current animation: ", animated_sprite.animation)
	print("Jump direction: ", jump_direction)
	print("Speed: ", speed)
# Add the die function to handle enemy death
func die():
	animated_sprite.play("Death")
	if animated_sprite.animation != "Death":
		queue_free()
