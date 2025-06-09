extends CanvasLayer

var counter := 0
var length := 0
var toDisplay := "Score: "

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$DisplayTimer.start()
	toDisplay += str(Variables.totalScoreCollected) + "/" + str(Variables.totalScore)
	pass


func _on_display_timer_timeout() -> void:
	counter += 1
	if counter == length+1:
		return
	else:
		$ScoreLabel.text = toDisplay.substr(0, counter)
		$DisplayTimer.start()

