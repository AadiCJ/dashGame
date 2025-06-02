extends Node

@warning_ignore_start("unused_signal")

signal dashStarted()
signal dashEnded()
signal dashesUpdated(dashCount: int)
signal dashPickedUp()
signal died()
signal isClimbing()
signal stoppedClimbing()
signal healthUpdated(currentHealth: int)

@warning_ignore_restore("unused_signal")
    
