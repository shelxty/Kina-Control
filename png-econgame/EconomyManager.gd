extends Node

# all my variables
var inflation_rate: float = 4.1 # the bank targets a 4.5% inflation rate but 2025 was a 4.1% 
var unemployment_rate: float = 2.6 # although there's a lot of underemployment, this is the official unemployment rate 
var gdp: float = 4.7 # gdp % growth currently real in 2025
var median_income: float = 9000 # pgk per year (formal sector approximation) 
var public_discontent_levels: float = 20 # on a 0-100 scale, where 0 = content and 100 = riots 
var national_reserves_amount: float = 3 # measured in billions: 3 billion

# -- this part is the natural rate except i need to figure out ways to get this to still be like... exciting because we can't just really be drifting towards stability every time. i need fun and exhileration ifykwim
const eq_gdp: float = 3.5
const eq_unemployment: float = 2.8 
const eq_inflation: float = 4.8 
const eq_income: float = 9000
const eq_discontent: float = 20 


# for the arduino values -- the pentiometers/knobs 
# so these are the variables and
var dial_spending: float = 0.5 # govt spending, where 0 = no spending and 1 = maximum spending kinda yk
var dial_taxes: float = 0.3 # tax levels where 0 = govt checks (so no taxes) and 1 = maximum taxes 
var dial_ior: float = 0.4 # interest on reserves rate  where 0 = 0% ior, 1 = maximum ior 

# these! are the constants for equilibrium stuff
const eq_dial_spending: float = 0.5 
const eq_dial_taxes: float = 0.3
const eq_dial_ior: float = 0.4 


# game system timer 
var process_timer: float = 0.0 
const tick_interval: float = 1.0 # every 1 second, the economy recalculates its health

signal economy_updated 

# to make the actual process calculating the timer 
func _process(delta: float): 
	process_timer += delta 
	if process_timer >= tick_interval: 
		process_timer = 0.0 # the moment the timer hits greater than 1 second, it resets to start the next downtime interval
		calculate_downtime_economy()
		
func calculate_downtime_economy(): 
	# the background will have some minor variance to keep the economy ineresting 
	var background_variance: float = randf_range(-0.6, 0.6) # NOTE!!!!!!!!!!!!!!!!!!!!!!! 
	# IF BACKGROUND VARIANCE!!!!!!!! IS A REALLY LARGE RANGE!!!!!!!!!!! LIKE -0.8 TO 0.8!!!!!!!!!!!!! THEN THE MARKET AND ECONOMY WILL BE MORE DRAMATIC AND MORE VOLATILE!!!!!!!!!!!!!!
	
	"""
	the MPC of papua new guinae is likely around 0.85 since it's a relatively poor nation. 
	therefore, spending multiplier = 1 / MPS = 1 / (1 - MPC) = 1 / (1 - 0.85) = 6.67 ish
	therefore, although this means a 6x impact on the gdp per dollar spent (money multiplier), i'll make the 
	formula for calculating gdp this:
	"""
	
	# as;dlfkjasd;lkfjasl;kdfja;lskdjf;laksdjf;laksdjf;laksdjf;laksdjf;lkasdjf 
	# anyways 
	# when the dials are at an equilibrium satee, there's no policy pressure so we have to calculate how much the dial is changed compared to the equilibrium levels 
	var spending_gap = dial_spending - eq_dial_spending 
	var taxes_gap = dial_taxes - eq_dial_taxes 
	var ior_gap = dial_ior - eq_dial_ior
	
	# okay in regards to the shocks that happen when dials are caused and stuff
	# since papua new guinea's highly exposed to commodity price swings like gold, copper, and palm oil (as well as other weather events, since it's basicaly on the equator and such) we have some shocks 
	
	# --- GDP COMPONENTS 
	var delta_gdp_spending =  spending_gap * 3.5 
	var delta_gdp_tax = -taxes_gap * 2.5 
	var delta_gdp_monetary_drag = -ior_gap * 1.5 
	
	var delta_gdp = delta_gdp_spending + delta_gdp_tax + delta_gdp_monetary_drag + ((eq_gdp - gdp) * 0.08) + background_variance
	
	# --- INFLATION COMPONENTS 
	var delta_inflation_demand_pull = spending_gap * 3 
	var delta_inflation_cost_push = taxes_gap * 1.2 
	var delta_inflation_monetary_cooling = -ior_gap * 3 
	
	var delta_inflation = delta_inflation_demand_pull + delta_inflation_cost_push + delta_inflation_monetary_cooling + ((eq_inflation - inflation_rate) * 0.05) + (background_variance * 0.5)
	
	# -- now for UNEMPLOYMENT!! 
	# aka what i'll be doing this stuff because game devs make no money
	var delta_unemployment_okun = (-delta_gdp) * 0.25 
	var delta_unemployment = delta_unemployment_okun + ((eq_unemployment - unemployment_rate) * 0.05) + (background_variance * 0.5) # the * 0.05 for (eq_unemployment - unemployment_rate) means the economy does try to self-adjust 
	
	
	# -- income income MONEYYYY
	# whats real? whats nominal? do we exist? is 42 the answer to life?
	var delta_income_growth = delta_gdp * 70 
	var delta_income_inflation_erosion = -(inflation_rate - 4.5) * 15
	
	var delta_income = delta_income_growth + delta_income_inflation_erosion + ((eq_income - median_income) * 0.1)
	
	
	# national reserves and banking and monetary policy (IOR)
	var delta_ior_tax = dial_taxes * 0.45
	var delta_ior_spending = -dial_spending * 0.33 
	
	var delta_ior = delta_ior_tax + delta_ior_spending
	
	
	# and now drumroll please
	# the combination of all of them
	# the thing that decides whether you win or lose this game
	# PUBLIC DISCONTENT LEVELS!!! 
	# well among the other things too lol but yeah
	### var discontent_pressure = ((inflation_rate - 4.1) * 0.65) + ((unemployment_rate - 2.6) * 1.5) + (taxes_gap * 8) - (max(0, gdp - 4.7) * 0.4) + (max(0, 4.7 - gdp) * 1.8) # THESE ARE THE DEFAULT VALUES BUT I LWOKEY WANT TO CHANGE IT 
	var discontent_pressure = ((inflation_rate - 4.1) * 1.8) + ((unemployment_rate - 2.6) * 3.5) + (taxes_gap * 12) - (max(0, gdp - 4.7) * 4)
	
	var delta_discontent = discontent_pressure * 0.18 + ((eq_discontent - public_discontent_levels) * 0.015) + (background_variance * 0.3)
	
	
	# NOW TO APPLY ALL THE CHANGES!!! onto the actual graphs 
	# this will either go really well or really poorly! 
	gdp = clamp(gdp + delta_gdp * 0.6, -9, 16) 
	"""change the delta_gdp * 0.6 -- like the 0.6, up to make it a more dramatic effect, and down to 0.3 or 0.4 ish to make the changes less wild 
	"""
	inflation_rate = clamp(inflation_rate + delta_inflation * 0.6, -20, 28)
	
	unemployment_rate = clamp(unemployment_rate + delta_unemployment * 0.6, 1, 18)
	
	median_income = clamp(median_income + delta_income * 0.6, 1000, 25000)
	
	national_reserves_amount = clamp(national_reserves_amount + delta_ior, 0, 10)
	
	public_discontent_levels = clamp(public_discontent_levels + delta_discontent, 0, 100)
	
	
	""" 
	THE FULL EXPLANATION FOR ALL THE VARIABLES AND STUFF IS ON THE GOOGLE DOC 
	it's titled "papua new guinea disaster response game" 
	i might link it to the readme too or something like that perhaps ;alsdkjfa;lskdfj
	"""
	
	emit_signal("economy_updated") # send signal to UI so that we know elements changed
	

	
	
