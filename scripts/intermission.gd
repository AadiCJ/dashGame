extends CanvasLayer

const SCORE_START = "Score: "
const DEATHS_START = "Deaths: "
const LEVEL_PATH = "res://levels/level_"



var counter := 0
var arrayCounter := 0
var length := 0
var toDisplay = {}
var score = ""
var deaths = ""
var isLastLevel: bool = Variables.isLastLevel
@onready var button = $VBoxContainer/NextLevelButton

func _ready() -> void:	
	score = str(Variables.score + Variables.dashes)
	deaths = str(Variables.deaths)
	Variables.totalScoreCollected += Variables.score + Variables.dashes


	var deathString = DEATHS_START + str(deaths)
	var scoreString = SCORE_START + score
	toDisplay = [
		{
			"value": "Level: " + str(Variables.currentLevel),
			"overwrite": true,
			"object": null
		},
		{
			"value": scoreString,
			"overwrite": true,
			"object": null
		},
		{
			"value": deathString,
			"overwrite": true,
			"object": null
		},
		{
			"value": "Next Level",
			"overwrite": false,
			"object": button

		}
	]
	length = len(toDisplay[0]["value"])

	for dict in toDisplay:
		if dict["overwrite"]:
			var child = Label.new()
			child.align = 1
			child.valign = 1
			child.add_theme_font_size_override("font_size", 32)
			dict["object"] = child
		if dict["object"] == button and isLastLevel:
			dict["value"] = "Go to end screen"
		$VBoxContainer.add_child(dict["object"])
		
		#add labels for everthing we need to display

	$VBoxContainer.move_child($VBoxContainer/NextLevelButton, -1)


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
	if isLastLevel: 
		get_tree().change_scene_to_file("res://ui/end_screen.tscn")
		return
	var nextLevel = Variables.currentLevel + 1
	var nextLevelPath = LEVEL_PATH + str(nextLevel) + ".tscn"
	Transition.change_scene(nextLevelPath)
