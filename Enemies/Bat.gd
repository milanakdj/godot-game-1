extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 300
export var FRICTION = 200
export var WANDER_TARGET_RANGE = 4

enum {
	IDLE,
	WANDER,
	CHASE
}
var knockback = Vector2.ZERO
var velocity = Vector2.ZERO

var state = IDLE

onready var stats = $Stats
onready var playerDetectoinZone = $PlayerDetectionZone
onready var sprite = $AnimatedSprite
onready var hurtBox = $HurtBox
onready var softCollisons = $SoftCollision
onready var wanderController = $WanderController

func _ready():
	print(stats.max_health)
	print(stats.health)
	state = pick_random_state([IDLE,WANDER])
	
func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO,FRICTION * delta)
			seek_player()
			if wanderController.time_left() == 0:
				update_wander()
		WANDER:
			seek_player()
			if wanderController.time_left() == 0:
				update_wander()
			accelerate_toward_point(wanderController.target_position, delta)
			
			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_RANGE:
				update_wander()
		CHASE:
			var player = playerDetectoinZone.player
			if player!=null:
				accelerate_toward_point(player.global_position, delta)
			else: 
				state = IDLE 
			
	
	if softCollisons.is_colliding():
		velocity += softCollisons.get_push_vector() * delta * 400	
	velocity = move_and_slide(velocity)
		
func seek_player():
	if playerDetectoinZone.can_see_player():
		state = CHASE
	
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_HurtBox_area_entered(area):
	stats.health -= area.damage #calling down and signaling up
	knockback = area.knockback_vector * 150
#area is basically the area of whaever enters the collisiion area
# and the knock back vector is one of the elements of the body of area
	hurtBox.create_hit_effect()

func accelerate_toward_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0

func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1,3))

func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
