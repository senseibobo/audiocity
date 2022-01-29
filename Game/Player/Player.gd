extends Node2D

var lane: int = 1
var game: Game
onready var particles_scene: PackedScene = preload("res://Game/Player/HitParticles.tscn")
var hit_timer: float
var hit_cooldown: float = 0.2


func _process(delta):
	hit_timer = move_toward(hit_timer,0,delta)
	if Input.is_action_just_pressed("move_up"): lane = clamp(lane - 1, 0, 1)
	if Input.is_action_just_pressed("move_down"): lane = clamp(lane + 1, 0, 1)
	if Input.is_action_just_pressed("black_hit"): hit("black")
	if Input.is_action_just_pressed("white_hit"): hit("white")
	if Input.is_action_just_pressed("switch_lane"): lane = 1-lane
	for l in 2:
		for color in ["white","black"]:
			if Input.is_action_just_pressed("lane"+str(l+1)+color):
				lane = l
				hit(color)
	for l in 2:
		if Input.is_action_just_pressed("lane_"+str(l+1)):
			lane = l
	global_position.y = lerp(global_position.y,300 + lane*120,45*delta)
	
func hit(color: String):
	if hit_timer > 0: return
	$AnimatedSprite.frame = 0
	$AnimatedSprite.play(color+"attack")
	if game.hit(lane, color):
		emit_particles(color)
	else:
		hit_timer = hit_cooldown

func adjust_bpm(bpm: float):
	$AnimatedSprite.speed_scale = lerp(bpm/60.0,1.0,0.5)

func emit_particles(color: String):
	var particles = particles_scene.instance()
	particles.texture = [
		preload("res://Textures/hitblackparticles.png"),
		preload("res://Textures/hitwhiteparticles.png")
	][int(color == "white")]
	add_child(particles)
	particles.emitting = true
	particles.position.x += 40.0
	yield(Tools.timer(0.3,particles),"timeout")
	particles.queue_free()


func _on_AnimatedSprite_animation_finished():
	if not $AnimatedSprite.animation in ["default","holdblack","holdwhite"]:
		$AnimatedSprite.play("default")
