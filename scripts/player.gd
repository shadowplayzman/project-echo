extends CharacterBody2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


@export_group("Movement")
@export var max_speed: float=300.0
@export var acceleration: float=300.0
@export var deacceleration: float=300.0

@export_group("Gravity")
@export var gravity:float=1800.0
@export var Jump_force:float=-650.0
@export var Jump_cut_multiplier:float=0.5

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_jump()
	variable_jump()
	move_horizontal(delta)
	move_and_slide()
	update_animation()
	
func move_horizontal(delta:float)->void:
	var direction :=Input.get_axis("move_left","move_right")
	
	if direction!=0:
		velocity.x=move_toward(velocity.x,direction*max_speed,acceleration*delta)
	else:
		velocity.x=move_toward(velocity.x,0.0,deacceleration*delta)
	if direction<0:
		animated_sprite.flip_h=true
	elif direction>0:
		animated_sprite.flip_h=false
		
func apply_gravity(delta:float)->void:
	if not is_on_floor():
		velocity.y+=gravity*delta
		
func handle_jump()->void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y=Jump_force
		
func variable_jump()->void:
	if Input.is_action_just_released("jump") and velocity.y<0:
		velocity.y*=Jump_cut_multiplier
		
func update_animation()->void:
	if not is_on_floor():
		animated_sprite.play("jump")
	elif abs(velocity.x)>5:
		animated_sprite.play("walk")
		
	else:
		animated_sprite.play("idle")
	
	
	
	
	
