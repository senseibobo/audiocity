extends Control

const speed: float = 15.0


var grade: String
var shown_score: float
var shown_hits: float
var shown_misses: float
var shown_accuracy: float
var shown_highscore: float
var shown_combo: float

func _ready():
	$Grade.modulate = Color(1,1,1,0)
	if Global.accuracy < 0.4: grade = "F"
	elif Global.accuracy < 0.7: grade = "D"
	elif Global.accuracy < 0.8: grade = "C"
	elif Global.accuracy < 0.9: grade = "B"
	elif Global.accuracy < 0.95: grade = "A"
	elif Global.accuracy < 1.0: grade = "S"
	else: grade = "S+"
	$Grade.text = grade
	yield(Tools.timer(1.0,self),"timeout")
	Tools.tween($Grade,"modulate",Color(1,1,1,0),Color(1,1,1,1),0.5)

func _process(delta):
	shown_score = lerp(shown_score,Global.score,speed*delta)
	shown_hits = lerp(shown_hits,Global.hits,speed*delta)
	shown_misses = lerp(shown_misses,Global.misses, speed*delta)
	shown_accuracy = lerp(shown_accuracy, Global.accuracy*100.0, speed*delta)
	shown_highscore = lerp(shown_highscore, Global.highscore, speed*delta)
	shown_combo = lerp(shown_combo, Global.max_combo, speed*delta)
	$ScoreAmount.text = str(round(shown_score))
	$HitAmount.text = str(round(shown_hits))
	$MissAmount.text = str(round(shown_misses))
	$Accuracy.text = "%.2f%%" % stepify(shown_accuracy,0.01)
	$HighscoreAmount.text = str(round(shown_highscore))
	$MaxCombo.text = str(round(shown_combo))


func _on_Back_pressed():
	Transition.transition()
	get_tree().change_scene_to(Global.main_scene)


func _on_Retry_pressed():
	Transition.transition()
	get_tree().change_scene_to(Global.game_scene)
