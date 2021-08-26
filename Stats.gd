extends Node


export(int) var max_health =1 #export allows to alter the values of max_health for different bats

onready var health = max_health setget set_health #because the updating only works after ready is called

signal no_health  

func set_health(value):#we use setter so that only when the value is set using set.health -=1 only then this is ran
	#also because when in bat tree from Stast we want to move upward in the tree so use signal
	health = value
	if health <=0:
		emit_signal("no_health")
