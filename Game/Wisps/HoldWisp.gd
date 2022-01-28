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
var end_texture: Texture


const start_black_texture = preload("res://Textures/startblack.png")
const mid_black_texture = preload("res://Textures/midblack.png")
const end_black_texture = preload("res://Textures/endblack.png")
const start_white_texture = preload("res://Textures/startwhite.png")
const mid_white_texture = preload("res://Textures/midwhite.png")
const end_white_texture = preload("res://Textures/endwhite.png")
	
func draw():
	match color:
		"white":
			start_texture = start_white_texture
			mid_texture = mid_white_texture
			end_texture = end_white_texture
		"black":
			end_texture = end_black_texture
			mid_texture = mid_black_texture
			start_texture = start_black_texture
	var y: float = 300.0+lane*120.0
	var start_size: Vector2 = start_texture.get_size()*2
	var start_position: Vector2 = Vector2(game.get_time_position(time)-start_size.x,y-start_size.y/2)
	var end_size: Vector2 = end_texture.get_size()*2
	var end_position: Vector2 = Vector2(game.get_time_position(time + length)-end_size.x,y-end_size.y/2)
	var mid_position: Vector2 = start_position + start_size*Vector2(1,0)
	var mid_size: Vector2 = Vector2(end_position.x-start_position.x-end_size.x,mid_texture.get_size().y)*2
	if pressable:
		game.draw_texture_rect(start_texture,Rect2(start_position,start_size),false)
	if is_being_pressed:
		mid_position.x = game.get_time_position(game.time)
	mid_size.x = game.get_time_position(time+length) - mid_position.x - end_size.x
	game.draw_texture_rect(mid_texture,Rect2(mid_position,mid_size),false)
	game.draw_texture_rect(end_texture,Rect2(end_position,end_size),false)

func hit():
	if pressable:
		is_being_pressed = true
		pressable = false
		print("p")

func on_process(delta: float):
	if is_being_pressed:
		if game.time > time+length:
			game.judge_wisp(self,"good")
		if game.player.lane != lane:
			game.judge_wisp(self,"bad")
		if not Input.is_action_pressed(color+"_hit"):
			game.judge_wisp(self,"bad")
	else:
		if time < game.time - game.timing:
			game.judge_wisp(self,"bad")
