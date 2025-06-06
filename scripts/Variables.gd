extends Node

enum scoreTypes {
	COIN = 1,
	ENEMY = 1,
}

var score = 0
var deaths = 0
var currentLevel = 0
var fallGravity = 0
var jumpGravity = 0
var jumpVelocity = 0
var isMobile = OS.has_feature("mobile")
@export var maxHealth = 3 if isMobile else 2


var totalScore = 0
#TODO: show the player your score/total score in the final screen


func _ready() -> void:
    SignalBus.displayScore.connect(getScore)
    SignalBus.levelEnd.connect(levelEnded)

func getScore(scoreIn):
    score = scoreIn

func levelEnded(levelIn):
    currentLevel = levelIn
