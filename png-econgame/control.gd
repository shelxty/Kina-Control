extends Control

@onready var unemployment_bar: ProgressBar = $CanvasLayer/UnemploymentBar
@onready var gdp_bar: ProgressBar = $CanvasLayer/GDPBar
@onready var inflation_bar: ProgressBar = $CanvasLayer/InflationBar
@onready var income_bar: ProgressBar = $CanvasLayer/IncomeBar
@onready var discontent_bar: ProgressBar = $CanvasLayer/DiscontentBar
@onready var reserves_bar: ProgressBar = $CanvasLayer/ReservesBar

func _ready(): 
	# connect to the global variable 
	EconomyManager.connect("economy_updated", _on_data_refreshed)
	update_displays()
	crisis_timer.wait_time = 5
	crisis_timer.one_shot = true 
	crisis_timer.start() 
	crisis_timer.connect("timeout", _on_crisis_timer_timeout)
	crisis_alert_panel.visible = false 
	
	
func _on_data_refreshed(): 
	update_displays()

func update_displays(): 
	gdp_bar.value = EconomyManager.gdp
	""" 
	explanation for how remap works because this lowkey confused me 
	float remap(value: float, istart: float, istop: float, ostart: float, ostop: float) 
	also godot documentation: https://docs.godotengine.org/en/stable/classes/class_@globalscope.html#class-globalscope-method-remap
	
	basically it maps a value from range [istart, istop] to [ostart, ostop]
	so like: remap(75, 0, 100, -1, 1) # Returns 0.5
	why? because 75 is 75% of the way from 0 to 100, and 0.5 is 75% of the way from -1 to 1
	so it basically remaps your value (in this case, the value of gdp from economymanager) to a number between 0 and 100 to update the gdp bar
	"""
	inflation_bar.value = remap(EconomyManager.inflation_rate, 0, 18, 0, 100)
	reserves_bar.value = remap(EconomyManager.national_reserves_amount, 0, 250, 0, 100)
	
	discontent_bar.value = EconomyManager.public_discontent_levels

# --------------------------
""" 
this part is to try and make an array of all the disasters that hit papua new guinea in 2025 and how they'd affect the economy
"""
var disasters = [
	{ 
		"title": "FATF has been internationally gray-listed",
		"gdp_modifier": 0.85, 
		"inflation_modifier": 1.4, 
		"discontent_modifier": 1.3
	},
	
	{ 
		"title": "FX Fuel Crisis: PUMA Energy Stoppage", 
		"gdp_modifier": 0.9, 
		"inflation_modifier": 1.4, 
		"discontent_modifier": 1.3
	},
	
	{ 
		"title": "Kina has devaluated",
		"inflation_modifier": 1.5, 
		"income_modifier": 0.85, 
		"discontent_modifier": 1.4
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
		pass 
		
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
	
	crisis_timer.wait_time = 5 
	crisis_timer.start() 
	
func clear_active_crisis(): 
	crisis_alert_panel.visible = false 
	active_crisis = {}
	
	# queue up the next background countdown of 10 seconds 
	crisis_timer.wait_time = 5 
	crisis_timer.start() 
