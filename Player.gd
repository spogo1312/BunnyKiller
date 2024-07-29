extends CharacterBody2D

# Declare member variables
var speed = 40
var gravity = 500
var jump_force = -100

# Declare nodes
@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	# Reset horizontal motion
	var motion = Vector2.ZERO

	# Input handling
	if Input.is_action_pressed("ui_right"):
		motion.x += speed
		animated_sprite.flip_h = false
		if is_on_floor():
			animated_sprite.play("Walk")
	elif Input.is_action_pressed("ui_left"):
		motion.x -= speed
		animated_sprite.flip_h = true
		if is_on_floor():
			animated_sprite.play("Walk")
	else:
		if is_on_floor():
			animated_sprite.play("Idle")

	# Jumping
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = jump_force
		animated_sprite.play("Jump")

	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	velocity.x = motion.x
	# Move the player
	move_and_slide()

	# Set the animation based on motion
	if not is_on_floor():
		animated_sprite.play("Jump")

func _ready():
	animated_sprite.play("Idle")
