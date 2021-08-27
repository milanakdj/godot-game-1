extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 300
export var FRICTION = 200

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

func _ready():
	print(stats.max_health)
	print(stats.health)
	
func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO,FRICTION * delta)
			seek_player()
		WANDER:
			pass
		CHASE:
			var player = playerDetectoinZone.player
			if player!=null:
				var direction = (player.global_position - global_position).normalized()
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			else: 
				state = IDLE 
			sprite.flip_h = velocity.x < 0
			
	velocity = move_and_slide(velocity)
		
func seek_player():
	if playerDetectoinZone.can_see_player():
		state = CHASE
	
func _on_HurtBox_area_entered(area):
	stats.health -= area.damage #calling down and signaling up
	knockback = area.knockback_vector * 150
#area is basically the area of whaever enters the collisiion area
# and the knock back vector is one of the elements of the body of area



func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
