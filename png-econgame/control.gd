extends Control

@onready var unemployment_bar: ProgressBar = $CanvasLayer/UnemploymentBar
# @onready var gdp_bar: ProgressBar = $CanvasLayer/GDPBar # lowkey realized that the gdp bar being a progress bar would not work since i want it to be a change in GDP (like % change in GDP) which can go into the negatives
# @onready var inflation_bar: ProgressBar = $CanvasLayer/InflationBar
@onready var income_bar: ProgressBar = $CanvasLayer/IncomeBar
@onready var income_label = $CanvasLayer/IncomeBar/IncomeLabel
@onready var discontent_bar: ProgressBar = $CanvasLayer/DiscontentBar

@onready var reserves_bar: ProgressBar = $CanvasLayer/ReservesBar
@onready var reserves_label = $CanvasLayer/ReservesBar/ReservesLabel

# i want to make a thing where like--when the gdp goes into the negatives, the bar turns red. when the gdp is in the positives, the bar turns green 
@onready var gdp_bar = $CanvasLayer/GDPBar
@onready var gdp_label = $CanvasLayer/GDPBar/GDPLabel

const gdp_positive_color = Color(0.409, 0.657, 0.402, 1.0)
const gdp_negative_color = Color(0.733, 0.202, 0.128, 1.0)
const gdp_zero_color = Color(0.478, 0.478, 0.478, 1.0) 

# lowkey wait i want to do the same thing for inflation LOL so i'll just copy paste the gdp stuff
@onready var inflation_bar = $CanvasLayer/InflationBar
@onready var inflation_label = $CanvasLayer/InflationBar/InflationLabel

const inflation_positive_color = Color(0.683, 0.468, 0.358, 1.0)
const inflation_negative_color = Color(0.375, 0.172, 0.156, 1.0)
const inflation_zero_color = Color(0.478, 0.478, 0.478, 1.0) 

func _ready(): 
	# connect to the global variable 
	game_over_panel.visible = false 
	EconomyManager.connect("economy_updated", _on_data_refreshed)
	update_displays()
	crisis_timer.wait_time = 5
	crisis_timer.one_shot = true 
	crisis_timer.start() 
	crisis_timer.connect("timeout", _on_crisis_timer_timeout)
	crisis_alert_panel.visible = false 
	# _check_discontent_threshold(discontent_bar.value)
	game_over_button.pressed.connect(_on_restart_button_pressed)
	discontent_bar.value_changed.connect(_check_discontent_threshold)
	
	
func _on_data_refreshed(): 
	update_displays()

func _process(delta: float): # process is a godot function that runs automatically ever yframe (so 60x a second)
	# delta is the time passed since the alst frame 
	if EconomyManager: # if the economymanager is loaded and exists (remember its a global script) then update_displays() is called 
		update_displays()

func update_gdp_display(): 
	# gdp_bar.value = EconomyManager.gdp
	var gdp_value: float = EconomyManager.gdp
	var gdp_stylebox: StyleBoxFlat = gdp_bar.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	
	if gdp_value > 0.0: 
		gdp_label.text = "GDP:     +" + str(snapped(gdp_value, 0.1)) + "%"
		gdp_stylebox.bg_color = gdp_positive_color
	if gdp_value < 0.0: 
		gdp_label.text = "GDP:      " + str(snapped(gdp_value, 0.1)) + "%"
		gdp_stylebox.bg_color = gdp_negative_color
		
	gdp_bar.add_theme_stylebox_override("panel", gdp_stylebox)
	
func update_inflation_display(): 
	# gdp_bar.value = EconomyManager.gdp
	var inflation_value: float = EconomyManager.inflation_rate
	var inflation_stylebox: StyleBoxFlat = inflation_bar.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	
	if inflation_value > 0.0: 
		inflation_label.text = "Inflation: +" + str(snapped(inflation_value, 0.1)) + "%"
		inflation_stylebox.bg_color = inflation_positive_color
	if inflation_value < 0.0: 
		inflation_label.text = "Deflation: " + str(snapped(inflation_value, 0.1)) + "%"
		inflation_stylebox.bg_color = inflation_negative_color
		
	inflation_bar.add_theme_stylebox_override("panel", inflation_stylebox)

func update_displays(): 
	update_gdp_display()
	update_inflation_display() 
	#if 
	#gdp_stylebox.set()
	
	""" 
	explanation for how remap works because this lowkey confused me 
	float remap(value: float, istart: float, istop: float, ostart: float, ostop: float) 
	also godot documentation: https://docs.godotengine.org/en/stable/classes/class_@globalscope.html#class-globalscope-method-remap
	
	basically it maps a value from range [istart, istop] to [ostart, ostop]
	so like: remap(75, 0, 100, -1, 1) # Returns 0.5
	why? because 75 is 75% of the way from 0 to 100, and 0.5 is 75% of the way from -1 to 1
	so it basically remaps your value (in this case, the value of gdp from economymanager) to a number between 0 and 100 to update the gdp bar
	"""
	# inflation_bar.value = remap(EconomyManager.inflation_rate, 0, 18, 0, 100)
	reserves_bar.value = remap(EconomyManager.national_reserves_amount, 0, 100, 0, 100)
	reserves_label.text = "$ in Reserves (billions): K" + str(reserves_bar.value)
	unemployment_bar.value = EconomyManager.unemployment_rate
	discontent_bar.value = EconomyManager.public_discontent_levels
	income_bar.value = remap(EconomyManager.median_income, 0, 100000, 0, 100)
	income_label.text = "Median Income (thousands): K" + str(income_bar.value)

# --------------------------
""" 
this part is to try and make an array of all the disasters that hit papua new guinea in 2025 and how they'd affect the economy
"""
var disasters = [
	{ 
		"title": "FATF has been internationally gray-listed",
		"gdp_modifier": 0.7, 
		"inflation_modifier": 1.4, 
		"discontent_modifier": 1.55
	},
	
	{ 
		"title": "FX Fuel Crisis: PUMA Energy Stoppage", 
		"gdp_modifier": 0.8, 
		"inflation_modifier": 1.4, 
		"discontent_modifier": 1.5
	},
	
	{ 
		"title": "Kina has devaluated",
		"inflation_modifier": 1.5, 
		"income_modifier": 0.85, 
		"discontent_modifier": 1.6
	}, 
	
	{ 
		"title": "ForEx scarcity and shortages",
		"inflation_modifier": 1.4, 
		"income_modifier": 0.8, 
		"discontent_modifier": 1.5
	}, 
	
	{ 
		"title": "Infrastructure bottlenecks", 
		# ↑ Spending = ↑ GDP,    ↑ Inflation,     ↓ Reserves
		"gdp_modifier": 1.3, 
		"inflation_modifier": 1.45, 
		"discontent_modifier": 1.4
	}, 
	
	{ 
		"title": "Corruption causes social unrest", 
		"income_modifier": 0.75, 
		"discontent_modifier": 1.5
	}
]


var active_crisis: Dictionary = {}
# --------------------------------------------

@onready var crisis_alert_panel = $CanvasLayer/CrisisAlertPanel
@onready var crisis_alert_text = $CanvasLayer/CrisisAlertPanel/Label
@onready var crisis_timer = $CrisisTimer


func _on_crisis_timer_timeout(): 
	if not crisis_alert_panel.visible: 
		trigger_random_crisis() 
	else: 
		clear_active_crisis() 
		
func trigger_random_crisis(): 
	active_crisis = disasters[randi() % disasters.size()] # pick a random disaster from the array of disasters 
	
	crisis_alert_text.text = active_crisis["title"] # the title of the disaster pops up 
	crisis_alert_panel.visible = true 
	
	# --- math formula 
	if active_crisis.has("reserves_modifier"): 
		EconomyManager.national_reserves_amount *= active_crisis["reserves_modifier"]
		
	if active_crisis.has("gdp_modifier"): 
		EconomyManager.gdp *= active_crisis["gdp_modifier"]
		
	if active_crisis.has("income_modifier"): 
		EconomyManager.median_income *= active_crisis["income_modifier"]
		
	if active_crisis.has("inflation_modifier"): 
		EconomyManager.inflation_rate *= active_crisis["inflation_modifier"]
		
	if active_crisis.has("discontent_modifier"): 
		EconomyManager.public_discontent_levels = clamp(EconomyManager.public_discontent_levels * active_crisis["discontent_modifier"], 0, 100)
	
	crisis_timer.wait_time = 10 
	crisis_timer.start() 
	
func clear_active_crisis(): 
	crisis_alert_panel.visible = false 
	active_crisis = {}
	
	# queue up the next background countdown of 10 seconds 
	crisis_timer.wait_time = 5 
	crisis_timer.start() 


# ------------------------------
# ----------------------------------------
# the game over screen part is right here 
#@onready var game_over_panel: Panel = $CanvasLayer/GameOverPanel
#@onready var game_over_label: Label = $CanvasLayer/GameOverPanel/VBoxContainer/GameOverLabel
#@onready var game_over_button: Button = $CanvasLayer/GameOverPanel/VBoxContainer/GameOverButton
@onready var game_over_panel: Panel = $CanvasLayer/GameOverPanel
@onready var game_over_button: Button = $CanvasLayer/GameOverPanel/GameOverButton
@onready var game_over_timer: Timer = $GameOverTimer



func _check_discontent_threshold(updated_value: float) -> void: 
	if updated_value < 25: # if the discontent value is low, we're in the green
		discontent_bar.modulate = Color(0.424, 0.55, 0.344, 1.0)
		# $CanvasLayer/DiscontentBar.set_background = Color(0.274, 0.366, 0.215, 1.0)
	elif updated_value >= 25 and updated_value < 50: 
		discontent_bar.modulate = Color(0.618, 0.49, 0.327, 1.0)
	elif updated_value >= 50 and updated_value < 75: 
		discontent_bar.modulate = Color("551213ff")
	else : # pass in a value called updated_value into this function and when that value surpasses 75, game over
		game_over_timer.wait_time = 1 
		game_over_timer.start()
		await game_over_timer.timeout # we have a timer here so that if events update to instantly shfit discontent levels to above 75%, it doesn't instantly just game over. the player at least knows what just happened
		game_over() 


	
func game_over() -> void: 
	game_over_panel.visible = true 
	get_tree().paused = true 

func _on_restart_button_pressed() -> void: 
	get_tree().paused = false 
	_reset_economy_data()
	get_tree().reload_current_scene()
	
	
func _reset_economy_data() -> void: 
	if EconomyManager: # if economymanager exists and is working...
		EconomyManager.gdp = 4.7 
		EconomyManager.inflation_rate = 4.1 
		EconomyManager.unemployment_rate = 2.6
		EconomyManager.national_reserves_amount = 3
		EconomyManager.median_income = 9000
		EconomyManager.public_discontent_levels = 20
