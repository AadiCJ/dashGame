extends Panel


func update(whole: bool):
	if whole: 
		$Sprite2D.frame = 44
	else: 
		$Sprite2D.frame = 46
