extends Node

# all my variables
var inflation_rate: float = 4.1 
var unemployment_rate: float = 2.6
var gdp: float = 4.7 # gdp % growth currently
var median_income: float = 9000
var public_discontent_levels: float = 20
var national_reserves_amount: float = 130 # measured in billions: 130 billion

# for the arduino values -- the pentiometers/knobs 
var dial_spending: float = 0.5 # govt spending
var dial_taxes: float = 0.3 # tax levels 
var dial_ior: float = 0.4 # interest on reserves rate 

# game system timer 
var process_timer: float = 0.0 
const tick_interval: float = 1.0 # every 1 second, the economy recalculates its health

# to make the actual process calculating the timer 
func _process(delta: float): 
	process_timer += delta 
	if process_timer >= tick_interval: 
		process_timer = 0.0 # the moment the timer hits greater than 1 second, it resets to start the next downtime interval
		calculate_downtime_economy()
		
func calculate_downtime_economy(): 
	# the background will have some minor variance to keep the economy ineresting 
	var R: float = randf_range(-0.15, 0.15)
	
	"""
	the MPC of papua new guinae is likely around 0.85 since it's a relatively poor nation. 
	therefore, spending multiplier = 1 / MPS = 1 / (1 - MPC) = 1 / (1 - 0.85) = 6.67 ish
	therefore, although this means a 6x impact on the gdp per dollar spent (money multiplier), i'll make the 
	formula for calculating gdp this:
	"""
	# these are all the changes (delta) calculated 
	var delta_gdp = (dial_spending * 1.4) - (dial_taxes * 1) - (dial_ior * 0.8) + R
	var delta_inflation = (dial_spending * 2) - ((1 - dial_taxes) * 0.8) - (dial_ior * 2.2) + R
	
	# and now these are when they're actually applied to the gdp 
	gdp = clamp(gdp + (delta_gdp * 0.1), -10, 15)
	inflation_rate = clamp(inflation_rate + (delta_inflation * 0.1), -2, 25)
	
	# unemployment however reacts inversely to gdp growth, so it has its own separate part here 
	var delta_unemployment = -(delta_gdp * 0.3) + (dial_ior * 0.5) + R
	unemployment_rate = clamp(unemployment_rate + (delta_unemployment * 0.05), 1, 15)
	
	# the national reserves amount fluctuates based on taxes and govt 
	var interest_balance = (dial_taxes * 8) - (dial_spending * 9)
	national_reserves_amount = clamp(national_reserves_amount + interest_balance, 0, 300)
	
	# median income will grow w/ a positive gdp but shrink with taxes
	median_income = clamp(median_income + (delta_gdp * 50) - (dial_taxes * 30), 4000, 20000)
	
	# public discontent levels respond to bad econ metrics 
	var discontent_score = (inflation_rate * 0.5) + (unemployment_rate * 1.2) + (dial_taxes * 10) - (gdp * 0.4)
	public_discontent_levels = clamp(public_discontent_levels + (discontent_score * 0.05), 0, 100)
	
	emit_signal("economy_updated") # send signal to UI so that we know elements changed
	
signal economy_updated 
	
	
