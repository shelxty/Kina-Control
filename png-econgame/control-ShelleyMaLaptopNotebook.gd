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
	
	
func _on_data_refreshed(): 
	update_displays()

func update_displays(): 
	gdp_bar.value = remap(EconomyManager.gdp, -5, 12, 0, 100)
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
