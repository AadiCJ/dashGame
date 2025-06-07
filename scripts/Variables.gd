extends Node

enum scoreTypes {
	COIN = 1,
	ENEMY = 1,
}

#level number: dashes you should have at the end of hte level
const IDEAL_DASHES = {
	1: 3, 
	2: 2,
	3: 2,
	4: 0,
	5: 1,
	6: 1,
}
const LEVEL_PATH = "res:///levels/level_"

var score = 0
var deaths = 0
var dashes = 0 #extra dashes = extra score
var currentLevel = 1
var fallGravity = 0
var jumpGravity = 0
var jumpVelocity = 0
var isLastLevel = false
var isMobile = OS.has_feature("mobile")
var levelCount = 0
@export var maxHealth = 3 if isMobile else 2


var totalScore = 0
var currentLevelScore = 0
#TODO: show the player your score/total score in the final screen


func _ready() -> void:
	for key in IDEAL_DASHES:
		totalScore += IDEAL_DASHES[key]

	while ResourceLoader.exists(LEVEL_PATH + str(levelCount + 1) + ".tscn"):
		levelCount += 1
	

	SignalBus.displayScore.connect(getScore)
	SignalBus.levelEnd.connect(levelEnded)


func getScore(scoreIn):
	score = scoreIn


func levelEnded(levelIn):
	if levelIn == levelCount:
		isLastLevel = true
	currentLevel = levelIn
	totalScore += currentLevelScore
