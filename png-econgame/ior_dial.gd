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
				_rotation_value(event.position)
				print(event.position)
				#drag_start_position = event.position # and set the mouse's position 
				#drag_start_value = value 
				#print(drag_start_value) 
				
			else: 
				if is_dragging: 
					is_dragging = false # player releases the mouse button 
					emit_signal("dial_released", value) 
					print(drag_start_value)
	
	elif event is InputEventMouseMotion and is_dragging: 
		_rotation_value(event.position)
		print(event.position)
		#var mouse_delta_y = event.position.y - drag_start_position.y # calculate distance (how far the mouse has moved vertically) since clicking 
		#var drag_final_value = drag_start_value - (mouse_delta_y * sensitivity)
		#value = clamp(drag_final_value, min_value, max_value)
		#print(value)

func _rotation_value(mouse_pos: Vector2): 
	var dial_center = size / 2 # finds the exact cinter of the dial
	var angle_radians = dial_center.angle_to_point(mouse_pos) # calculate distance from center of dial to mouse position 
	# godot has built-in angle_to_point, which returns value from 9 o'clock (-) to 3 o'clock (+)
	
	var angle_to_degrees = rad_to_deg(angle_radians)
	var angle_adjustment = angle_to_degrees + 90 # set 0 degrees to the top (12 o'clock) instead of 3 o'clock 
	
	if angle_adjustment < 0: # sit between 0 and 360 degrees
		angle_adjustment += 360
		
	var percentage_value = remap(angle_adjustment, 0, 360, min_value, max_value) # map the 0-360 value directly to 0-100 progress bar
	# and if it's dragged beyond 360, it's still clamped between 0 and 360 
	
	value = clamp(percentage_value, min_value, max_value)
