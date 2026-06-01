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
