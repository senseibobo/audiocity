extends Node

var transition_scene: PackedScene = preload("res://Global/Transition.tscn")
var transitioning: bool = false
var background_color: Color = Color.black

func _input(event):
	if event.is_action("fullscreen"):
		if event.is_pressed():
			OS.window_fullscreen = !OS.window_fullscreen

func tween(object,property,from,to,duration,tw1 = Tween.TRANS_LINEAR,tw2 = Tween.EASE_IN_OUT, physics = false) -> Tween:
	var tween = Tween.new()
	get_tree().current_scene.add_child(tween)
	tween.connect("tween_all_completed",tween,"queue_free")
	tween.interpolate_property(object,property,from,to,duration,tw1,tw2)
	tween.start()
	if physics:
		tween.playback_process_mode = 2
	return tween

func timer(time,object = get_tree().current_scene) -> Timer:
	var timer = Timer.new()
	object.add_child(timer)
	timer.start(time)
	timer.connect("timeout",timer,"queue_free")
	return timer

func transition():
	if transitioning: return
	var transition = transition_scene.instance()
	Global.add_child(transition)
	transition.start()
	return transition

func transition_to(scene):
	var transition = transition()
	var method: String
	if scene is PackedScene: method = "change_scene_to"
	elif scene is String: method = "change_scene"
	get_tree().call(method,scene)
	return transition
