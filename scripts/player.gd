extends CharacterBody2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dust_clouds: GPUParticles2D = $jumpDust/dustClouds
@onready var jump_debris: GPUParticles2D = $jumpDust/jumpDebris


@export_group("Movement")
@export var max_speed: float=300.0
@export var acceleration: float=300.0
@export var deceleration: float=300.0

@export_group("Gravity")
@export var gravity:float=1800.0
@export var jump_velocity:float=-650.0
@export var jump_cut_multiplier:float=0.5

@export_group("jump assist")
@export var coyote_time: float=0.1
@export var jump_buffer_time:float=0.1

@export_group("dash")
@export var dash_speed:float=900.0
@export var dash_duration:float=0.15
@export var dash_cooldown : float=0.3

var coyote_timer:float=0.0
var jump_buffer_timer:float=0.0

var is_dashing:bool =false
var dash_timer:float=0.0

var dash_available:bool=true
var dash_started_on_ground: bool = false
var dash_cooldown_timer:float=0.0

var dash_direction :Vector2=Vector2.ZERO

@export_group("Respawn")
@export var respawn_delay=0.5

var is_dead:bool=false
var respawn_position=Vector2.ZERO

func _ready() -> void:
	respawn_position=global_position

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	update_ground_dash_cooldown(delta)
	update_air_dash_reset()
	if Input.is_action_just_pressed("dash"):
		start_dash()
		
	if is_dashing:
		update_dash(delta)
	else:
		apply_gravity(delta)
		update_coyote_timer(delta)
		update_jump_buffer_timer(delta)
		handle_jump()
		variable_jump()
		move_horizontal(delta)
		
	move_and_slide()
	update_animation()
	
func play_animation(animation_name:String)->void:
	if animated_sprite.animation!=animation_name:
		animated_sprite.play(animation_name)
		
func update_coyote_timer(delta:float)->void:
	if is_on_floor():
		coyote_timer=coyote_time
	else:
		coyote_timer=max(coyote_timer - delta, 0.0)
	
func update_jump_buffer_timer(delta:float)->void:
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer=jump_buffer_time
	else:
		jump_buffer_timer=max(jump_buffer_timer - delta, 0.0)
func move_horizontal(delta:float)->void:
	var direction :=Input.get_axis("move_left","move_right")
	
	if direction!=0:
		velocity.x=move_toward(velocity.x,direction*max_speed,acceleration*delta)
	else:
		velocity.x=move_toward(velocity.x,0.0,deceleration*delta)
	if direction<0:
		animated_sprite.flip_h=true
	elif direction>0:
		animated_sprite.flip_h=false
		
func apply_gravity(delta:float)->void:
	if not is_on_floor():
		velocity.y+=gravity*delta
		
func handle_jump()->void:
	if jump_buffer_timer>0.0 and coyote_timer>0.0:
		coyote_timer=0.0
		jump_buffer_timer=0.0
		dust_clouds.restart()
		dust_clouds.emitting = true

		jump_debris.restart()
		jump_debris.emitting = true

		velocity.y=jump_velocity
		
func variable_jump()->void:
	if !Input.is_action_pressed("jump") and velocity.y < 0:
		velocity.y*=jump_cut_multiplier
		
func update_animation()->void:
	if is_dashing:
		play_animation("dash")
	elif not is_on_floor():
		play_animation("jump")
	elif abs(velocity.x) > 5:
		play_animation("walk")
	else:
		play_animation("idle")
		
func start_dash()->void:
	if not dash_available:
		return
	var input_direction:=Vector2(Input.get_axis("move_left","move_right"),Input.get_axis("move_up","move_down"))
	
	if input_direction==Vector2.ZERO:
		if animated_sprite.flip_h:
			input_direction=Vector2.LEFT
		else:
			input_direction=Vector2.RIGHT
	dash_direction=input_direction.normalized()
	
	dash_started_on_ground=is_on_floor()
	is_dashing=true
	dash_available=false
	dash_timer=dash_duration
	
func update_dash(delta:float)->void:
	if not is_dashing:
		return
	velocity=dash_direction*dash_speed
	
	dash_timer-=delta
	if dash_timer<=0.0:
		is_dashing=false
		if dash_started_on_ground:
			dash_cooldown_timer=dash_cooldown
		
func update_air_dash_reset()->void:
	if (not dash_started_on_ground 
		and is_on_floor() 
		and not is_dashing
	):
		dash_available=true
		
func update_ground_dash_cooldown(delta:float)->void:
	if dash_cooldown_timer<=0.0:
		return
	dash_cooldown_timer=max(dash_cooldown_timer-delta,0.0)
	
	if dash_cooldown_timer==0.0:
		dash_available=true

func die()->void:
	if is_dead:
		return
	is_dead=true
	play_animation("die")
	
	is_dashing = false
	dash_timer = 0.0
	dash_direction = Vector2.ZERO
	velocity=Vector2.ZERO
	
	await get_tree().create_timer(respawn_delay).timeout
	
	global_position=respawn_position
	velocity=Vector2.ZERO
	
	is_dead=false
	
	
func set_respawn_position(position:Vector2)->void:
	respawn_position=position
	
	
	
	
	
	
