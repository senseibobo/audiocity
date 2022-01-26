extends Node2D

var lane: int = 1
var game: Game

func _ready():
	global_position.x = 200

func _process(delta):
	if Input.is_action_just_pressed("move_up"):
		lane = clamp(lane - 1, 0, 2)
	if Input.is_action_just_pressed("move_down"):
		lane = clamp(lane + 1, 0, 2)
	if Input.is_action_just_pressed("black_hit"):
		hit("black")
	if Input.is_action_just_pressed("white_hit"):
		hit("white")
	for l in 3:
		if Input.is_action_just_pressed("lane_"+str(l+1)):
			lane = l
	global_position.y = lerp(global_position.y,360 + (lane-1)*120,32*delta)
	
func hit(color: String):
	game.hit(lane)
