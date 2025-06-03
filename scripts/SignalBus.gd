extends Node

enum scoreTypes {
	COIN = 1,
	ENEMY = 1,
}
var score = 0
var deaths = 0
var currentLevel = 0

func _ready() -> void:
    displayScore.connect(getScore)
    levelEnd.connect(levelEnded)

func getScore(scoreIn):
    score = scoreIn

func levelEnded(currentLevel):
    self.currentLevel = currentLevel

@warning_ignore_start("unused_signal")

signal dashStarted()
signal dashEnded()
signal dashesUpdated(dashCount: int)
signal dashPickedUp()
signal died()
signal isClimbing()
signal stoppedClimbing()
signal healthUpdated(currentHealth: int)
signal damage(value: int)
signal scoreChange(scoreChange: int)
signal levelEnd(currentLevel: int)
signal displayScore(score: int)
signal testSignal()


@warning_ignore_restore("unused_signal")
