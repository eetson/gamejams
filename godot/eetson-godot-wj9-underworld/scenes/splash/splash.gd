extends Control

onready var buttonFakePress = $Button

# Press Any Key
func _input(event):
	if event is InputEventKey:
		buttonFakePress._on_Button_pressed()

func _on_Timer_timeout():
	buttonFakePress._on_Button_pressed()
