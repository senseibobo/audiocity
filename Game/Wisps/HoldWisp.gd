extends Wisp
class_name HoldWisp

var pressable: bool = true
var is_being_pressed: bool = false
var length: float
const width: float = 72.0
var fail_timer: float = 0.2
var particles_array: Array
var start_texture: Texture
var mid_texture: Texture
var mid_texture_mid: Texture
var mid_texture_long: Texture
var end_texture: Texture


const start_black_texture = preload("res://Textures/startblack.png")
const mid_black_texture = preload("res://Textures/midblack.png")
const end_black_texture = preload("res://Textures/endblack.png")
#const mid_long_black_texture = preload("res://Textures/midblacklong.png")
#const mid_mid_black_texture = preload("res://Textures/midblackmid.png")
const start_white_texture = preload("res://Textures/startwhite.png")
const mid_white_texture = preload("res://Textures/midwhite.png")
#const mid_long_white_texture = preload("res://Textures/midwhitelong.png")
#const mid_mid_white_texture = preload("res://Textures/midwhitemid.png")
const end_white_texture = preload("res://Textures/endwhite.png")
const black_slide_particles = preload("res://Textures/hitblackparticles.png")
const white_slide_particles = preload("res://Textures/hitwhiteparticles.png")
	
func draw(modulate: Color = Color.white):
	match color:
		"white":
			start_texture = start_white_texture
			mid_texture = mid_white_texture
#			mid_texture_mid = mid_mid_white_texture
#			mid_texture_long = mid_long_white_texture
			end_texture = end_white_texture
		"black":
			end_texture = end_black_texture
			mid_texture = mid_black_texture
#			mid_texture_mid = mid_mid_black_texture
#			mid_texture_long = mid_long_black_texture
			start_texture = start_black_texture
	var y: float = 300.0+lane*120.0
	var start_size: Vector2 = start_texture.get_size()*2
	var start_position: Vector2 = Vector2(game.get_time_position(time)-start_size.x,y-start_size.y/2)
	var end_size: Vector2 = end_texture.get_size()*2
	var end_position: Vector2 = Vector2(game.get_time_position(time + length),y-end_size.y/2)
	var mid_position: Vector2 = start_position + start_size*Vector2(1,0)
	var mid_size: Vector2 = Vector2(0,mid_texture.get_size().y)*2
	if pressable:
		game.draw_texture_rect(start_texture,Rect2(start_position,start_size),false,modulate)
	if is_being_pressed:
		mid_position.x = game.get_time_position(game.time) - 84.0
	mid_size.x = game.get_time_position(time+length) - mid_position.x
	game.draw_texture_rect(mid_texture,Rect2(mid_position,mid_size),false,modulate)
	game.draw_texture_rect(end_texture,Rect2(end_position,end_size),false,modulate)

func hit():
	if pressable:
		is_being_pressed = true
		pressable = false
		game.player.get_node("SlideParticles").emitting = true
		game.player.get_node("SlideParticles").texture = [
			white_slide_particles,
			black_slide_particles
		][int(color == "black")]
		game.player.get_node("AnimatedSprite").play("hold"+color)
		
func judge(judgement: String):
	if not pressable:
		game.player.get_node("SlideParticles").emitting = false
		game.player.get_node("AnimatedSprite").play("default")
	game.judge_wisp(self,judgement)

func on_process(delta: float):
	if is_being_pressed:
		if game.time > time+length:
			judge("good")
		if game.player.lane != lane:
			judge("bad")
		if not Input.is_action_pressed(color+"_hit"):
			is_being_pressed = false
			judge("bad")
	else:
		if time < game.time - game.timing*game.speed:
			judge("bad")
