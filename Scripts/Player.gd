extends CharacterBody2D

# Declare member variables
@export var speed = 40
@export var gravity = 500
@export var jump_force = -100
@export var max_jump_time = 0.2 # Maximum time the jump can be held
@export var coyote_time = 0.1 # Time window to allow jumps after leaving the ground
@export var is_double_slashing = false
@export var landing_frame_duration = 0.5 # Duration to show the landing frame
@export var slime_scene = preload("res://Scenes/slime.tscn")

# Declare nodes
@onready var animated_sprite = $AnimatedSprite2D
@onready var animationPlayer = $AnimationPlayer
@onready var spriteGroundAttack = $Sprite2D
@onready var GroundAttackHitbox = $Sprite2D/HitBox/CollisionShape2D

# Variables to handle jump timing
var jump_time = 0
var is_jumping = false
var coyote_timer = 0
var previous_velocity_y = 0
var landing_frame_timer = 0.0
var show_landing_frame = false


signal spawned
func _ready():
	animated_sprite.play("Idle")
	emit_signal("spawned")

func _physics_process(delta):
	# Reset horizontal motion
	var motion = Vector2.ZERO
	if( not is_double_slashing):
		animationPlayer.play("Default")
		spriteGroundAttack.hide()
		animated_sprite.show()
		
	else:
		spriteGroundAttack.show()
		animated_sprite.hide()
	# DoubleSlash action
	if Input.is_action_just_pressed("DoubleSlash") and is_on_floor():
		is_double_slashing = true
		animationPlayer.play("GroundAttack")
		return  # Skip the rest of the process while DoubleSlash is playing

	# If DoubleSlash animation is playing, move the player
	if is_double_slashing:
		if not animationPlayer.is_playing() or animationPlayer.current_animation != "GroundAttack":
			is_double_slashing = false
		else:
			# Apply movement during DoubleSlash
			position += motion
			return

	# Input handling
	if Input.is_action_pressed("ui_right"):
		motion.x += speed
		animated_sprite.flip_h = false
		spriteGroundAttack.flip_h = false
		spriteGroundAttack.position.x = 15
		GroundAttackHitbox.position.x = 15
		
		if is_on_floor() and !show_landing_frame:
			animated_sprite.play("Walk")
	elif Input.is_action_pressed("ui_left"):
		motion.x -= speed
		animated_sprite.flip_h = true
		spriteGroundAttack.flip_h = true
		spriteGroundAttack.position.x = -13
		GroundAttackHitbox.position.x = -13
		
		if is_on_floor() and !show_landing_frame:
			animated_sprite.play("Walk")
	else:
		if is_on_floor() and !show_landing_frame:
			animated_sprite.play("Idle")

	# Update coyote timer
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	# Jumping
	if Input.is_action_just_pressed("ui_up") and (is_on_floor() or coyote_timer > 0):
		velocity.y = jump_force
		is_jumping = true
		jump_time = 0
		animated_sprite.play("Jump")
		coyote_timer = 0 # Reset coyote timer after jump
	
	if Input.is_action_pressed("ui_up") and is_jumping:
		if jump_time < max_jump_time:
			jump_time += delta
		else:
			is_jumping = false
	else:
		is_jumping = false

	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		if is_jumping and jump_time < max_jump_time:
			velocity.y = jump_force  # Maintain jump force while holding jump button

	velocity.x = motion.x
	
	# Move the player
	move_and_slide()

	# Check if the player has landed
	if is_on_floor() and previous_velocity_y > 200 and !show_landing_frame:
		animated_sprite.frame = 7  # Show frame 7 upon landing
		show_landing_frame = true
		landing_frame_timer = landing_frame_duration

	# Handle landing frame timer
	if show_landing_frame:
		landing_frame_timer -= delta
		if landing_frame_timer <= 0:
			show_landing_frame = false
			animated_sprite.play("Idle")

	# Update previous velocity for the next frame
	previous_velocity_y = velocity.y

	# Set the animation frame based on the vertical velocity
	if animated_sprite.animation == "Jump" and !show_landing_frame:
		update_jump_frame()

	# Set the animation based on motion
	if not is_on_floor() and !is_jumping:
		animated_sprite.play("Jump")

func update_jump_frame():
	if animated_sprite.animation == "Jump":
		if velocity.y <= -70:
			animated_sprite.frame = 2  # Play the frame for high upward velocity
		elif velocity.y > -70 and velocity.y < -20:
			animated_sprite.frame = 3  # Play the frame for moderate velocity (near peak of jump)
		elif velocity.y > -20 and velocity.y < 20:
			animated_sprite.frame = 4
		elif velocity.y > 20 and velocity.y < 70:
			animated_sprite.frame = 5
		elif velocity.y > 200:
			animated_sprite.frame = 6
func _on_Player_spawned():
	# Instantiate the slime scene
	var slime = slime_scene.instantiate()
	add_child(slime)
	slime.set_player(self) # Pass the player reference to the slime

