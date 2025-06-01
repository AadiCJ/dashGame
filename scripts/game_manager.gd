extends Node


signal dashUpdated()


var dashes = 3:
    get():
        return dashes
    set(value):
        dashes = clamp(dashes + value, 0, 3)
        dashUpdated.emit()  



func _on_dash_pickup_dash_picked_up() -> void:
    dashes = 1
