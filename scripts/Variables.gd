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



func _ready() -> void:
    SignalBus.displayScore.connect(getScore)
    SignalBus.levelEnd.connect(levelEnded)

func getScore(scoreIn):
    score = scoreIn

func levelEnded(levelIn):
    currentLevel = levelIn
