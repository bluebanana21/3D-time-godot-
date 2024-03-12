class_name  interactable
extends StaticBody3D


@export var prompt_message = "interact"
@export var prompt_action = "interact"


func get_prompt():
	var key_name = ""
	for action in InputMap.action_get_events(prompt_action):
		if action is InputEventKey:
			key_name = OS.get_keycode_string(action.keycode)
	return prompt_message + "\n[" + prompt_action + "]"
	#return 
