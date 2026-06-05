extends TextureProgressBar

var is_dragging: bool = false 
var drag_start_position: Vector2 = Vector2.ZERO 
var drag_start_value: float = 0 

@export var sensitivity: float = 0.5 
# basically lower sensitivity means slower (more precise) tracking 
# this can be edited in the inspector tab now 

signal dial_released(drag_final_value: float) # create signal: variable name "drag_final_value", type float 

func _gui_input(event: InputEvent): 
	if event is InputEventMouseButton: 
		print("mouse clicked")
		if event.button_index == MOUSE_BUTTON_LEFT: # upon the left mouse button's press 
			if event.pressed: 
				is_dragging = true # we set "is the mouse currently being dragged?" to true 
				drag_start_position = event.position # and set the mouse's position 
				drag_start_value = value 
				print(drag_start_value) 
				
			else: 
				if is_dragging: 
					is_dragging = false # player releases the mouse button 
					emit_signal("dial_released", value) 
					print(drag_start_value)
	
	elif event is InputEventMouseMotion and is_dragging: 
		var mouse_delta_y = event.position.y - drag_start_position.y # calculate distance (how far the mouse has moved vertically) since clicking 
		var drag_final_value = drag_start_value - (mouse_delta_y * sensitivity)
		value = clamp(drag_final_value, min_value, max_value)
		print(value)
