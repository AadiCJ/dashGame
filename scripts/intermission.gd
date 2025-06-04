extends Node2D

const SCORE_START = "Score: "
const DEATHS_START = "Deaths: "
const LEVEL_PATH = "res://levels/level_"



var counter := 0
var arrayCounter := 0
var length := 0
var toDisplay = {}
var score = ""
var deaths = ""

func _ready() -> void:
	score = str(Variables.score)
	deaths = str(Variables.deaths)


	var deathString = DEATHS_START + str(deaths)
	var scoreString = SCORE_START + score
	toDisplay = [
		{
			"value": scoreString,
			"object": null
		},
		{
			"value": deathString,
			"object": null
		},
	]
	length = len(toDisplay[0]["value"])

	for dict in toDisplay:
		#add labels for everthing we need to display
		var child = Label.new()	
		child.align = 1
		child.valign = 1
		child.add_theme_font_size_override("font_size", 32)
		dict["object"] = child
		$VBoxContainer.add_child(child)
	
	for child in $VBoxContainer.get_children():
		if is_instance_of(child, Button):
			$VBoxContainer.move_child(child, -1)

	$DisplayTimer.start()


#makes the score and deaths show up nicely
func _on_display_timer_timeout() -> void:
	counter += 1
	if counter == length+1:
		arrayCounter += 1
		if arrayCounter >= len(toDisplay):
			return
		length = len(toDisplay[arrayCounter]["value"])
		counter = 0
		return
	else:
		if arrayCounter >= len(toDisplay):
			return
		var dict = toDisplay[arrayCounter]
		dict["object"].text = dict["value"].substr(0, counter)
		$DisplayTimer.start()


func _on_button_pressed() -> void:
	var nextLevel = Variables.currentLevel + 1
	var nextLevelPath = LEVEL_PATH + str(nextLevel) + ".tscn"
	Transition.change_scene(nextLevelPath)
