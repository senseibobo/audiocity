extends PopupPanel


var points: Array
var point_scene = preload("res://Editor/Point.tscn")


func update_points():
	var children = $HBoxContainer.get_children()
	children.erase($HBoxContainer/Labels)
	for child in children:
		child.queue_free()
	var index = 0
	for point in points:
		var point_inst = point_scene.instance()
		$HBoxContainer.add_child(point_inst)
		point_inst.get_node("SpinBox").value = point.x
		point_inst.get_node("OptionButton").selected = int(point.y)
		point_inst.get_node("SpinBox").connect("value_changed",self,"time_changed",[index])
		point_inst.get_node("OptionButton").connect("item_selected",self,"lane_changed",[index])
		index += 1
