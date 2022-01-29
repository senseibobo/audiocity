extends ColorRect


var main_scene: PackedScene

func _ready():
	var thread = Thread.new()
	thread.start(self,"load_main")
	thread.wait_to_finish()

func load_main():
	main_scene = load("res://Menu/Main.tscn")


func _process(delta):
	if Input.is_action_just_pressed("editor_escape"):
		if not get_tree().paused:
			pause()
		else:
			unpause()

func pause():
	$Tween.interpolate_property(
		self,
		"rect_position",
		Vector2(0,-720),
		Vector2(0,0),
		0.3,
		Tween.TRANS_CUBIC,
		Tween.EASE_OUT	
	)
	$Tween.start()
	get_tree().paused = true

func unpause():
	$Tween.interpolate_property(
		self,
		"rect_position",
		Vector2(0,0),
		Vector2(0,-720),
		0.3,
		Tween.TRANS_CUBIC,
		Tween.EASE_OUT	
	)
	$Tween.start()
	yield($Tween,"tween_all_completed")
	get_tree().paused = false
			


func _on_Resume_pressed():
	unpause()
	


func _on_Retry_pressed():
	get_tree().paused = false
	Transition.transition()
	get_tree().reload_current_scene()


func _on_Quit_pressed():
	get_tree().paused = false
	Transition.transition()
	get_tree().change_scene_to(main_scene)
