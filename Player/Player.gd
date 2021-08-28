extends KinematicBody2D

export var ACCELARATION = 500
export var MAX_SPEED = 100 #max speed for the accelaration
export var FRICTION = 500
export var ROLL_SPEED = 125

enum {
	MOVE, 
	ROLL,
	ATTACK
}
var state = MOVE

var velocity = Vector2.ZERO
var stats = PlayerStats

onready var animationPlayer= $AnimationPlayer
onready var animationTree= $AnimationTree
onready var animationState= animationTree.get("parameters/playback")
onready var swordHitBox = $HitboxPivot/SwordHitBox
onready var hurtBox = $HurtBox

var roll_vector = Vector2.DOWN#remember the direction we moving in; input vector while attempting to move
#don't want zero as we don't roll when zero, only in one direction
func _ready():
	randomize()
	stats.connect("no_health", self, "queue_free")
	swordHitBox.knockback_vector = roll_vector
	animationTree.active = true
	
func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)	
		ROLL:
			roll_state()
		ATTACK:
			attack_state()
	
func attack_state():
	animationState.travel("Attack")

func roll_state():
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()
	
func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")	
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")	
	input_vector = input_vector.normalized()#helps with managing the diagonal to so be faster than other movements
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitBox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position",input_vector)#only update when the player stop so remembers the direction the player was facing 
		animationTree.set("parameters/Run/blend_position",input_vector)
		animationTree.set("parameters/Attack/blend_position",input_vector)
		animationTree.set("parameters/Roll/blend_position",input_vector)
		animationState.travel("Run")
		#velocity += input_vector *ACCELARATION * delta 
		#velocity = velocity.clamped(MAX_SPEED*delta)#instead of time to the real world time its frame based
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELARATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION*delta)
		
# warning-ignore:return_value_discarded
	move()
	
	if Input.is_action_just_pressed("attack"):
		velocity=Vector2.ZERO
		state = ATTACK
		
	if Input.is_action_just_pressed("roll")	:
		state = ROLL
		

	
func move():
	velocity = move_and_slide(velocity)
	
func attack_animiation_finished():
	state = MOVE

func roll_animation_finished():
	velocity = velocity * 0.8
	state = MOVE
	
	


func _on_HurtBox_area_entered(area):
	stats.health -=1
	hurtBox.start_invincibility(0.5)
	hurtBox.create_hit_effect()
	
