extends CanvasLayer

var heartPanel = preload("res://scenes/heart_panel.tscn")
var maxHearts = 3

func _ready() -> void:
	SignalBus.dashesUpdated.connect(_on_dashes_updated)
	SignalBus.healthUpdated.connect(_on_health_updated)
	for i in range(maxHearts):
		var child = heartPanel.instantiate()
		$HeartContainer.add_child(child)


func _on_dashes_updated(dashCount) -> void:
	$Dashes.text = str(dashCount)	

func _on_health_updated(currentHealth: int) -> void:
	var hearts = $HeartContainer.get_children()

	for i in range(hearts.size()):
		if i < currentHealth:
			hearts[i].update(true)
		else:
			hearts[i].update(false)
