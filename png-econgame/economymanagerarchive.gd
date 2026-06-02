# essentially this is a script that was just my previous EconomyManager except i realized i have WAY TOO MANY MISTAKES so it's all just here in case i really really want it so that i can saafely delete every unnecessary thing from the other script lolz

#extends Node
#
## all my variables
#var inflation_rate: float = 4.1 # the bank targets a 4.5% inflation rate but 2025 was a 4.1% 
#var unemployment_rate: float = 2.6 # although there's a lot of underemployment, this is the official unemployment rate 
#var gdp: float = 4.7 # gdp % growth currently real in 2025
#var median_income: float = 9000 # pgk per year (formal sector approximation) 
#var public_discontent_levels: float = 20 # on a 0-100 scale, where 0 = content and 100 = riots 
#var national_reserves_amount: float = 130 # measured in billions: 130 billion
#
## -- this part is the natural rate except i need to figure out ways to get this to still be like... exciting because we can't just really be drifting towards stability every time. i need fun and exhileration ifykwim
#const eq_gdp: float = 3.5
#const eq_unemployment: float = 2.8 
#const eq_inflation: float = 4.8 
#const eq_income: float = 9000
#const eq_discontent: float = 20 
#
#
## for the arduino values -- the pentiometers/knobs 
## so these are the variables and
#var dial_spending: float = 0.5 # govt spending, where 0 = no spending and 1 = maximum spending kinda yk
#var dial_taxes: float = 0.3 # tax levels where 0 = govt checks (so no taxes) and 1 = maximum taxes 
#var dial_ior: float = 0.4 # interest on reserves rate  where 0 = 0% ior, 1 = maximum ior 
#
## these! are the constants for equilibrium stuff
#const eq_dial_spending: float = 0.5 
#const eq_dial_taxes: float = 0.3
#const eq_dial_ior: float = 0.4 
#
#
## game system timer 
#var process_timer: float = 0.0 
#const tick_interval: float = 1.0 # every 1 second, the economy recalculates its health
#
## to make the actual process calculating the timer 
#func _process(delta: float): 
	#process_timer += delta 
	#if process_timer >= tick_interval: 
		#process_timer = 0.0 # the moment the timer hits greater than 1 second, it resets to start the next downtime interval
		#calculate_downtime_economy()
		#
#func calculate_downtime_economy(): 
	## the background will have some minor variance to keep the economy ineresting 
	#var background_variance: float = randf_range(-0.3, 0.3)
	#
	#"""
	#the MPC of papua new guinae is likely around 0.85 since it's a relatively poor nation. 
	#therefore, spending multiplier = 1 / MPS = 1 / (1 - MPC) = 1 / (1 - 0.85) = 6.67 ish
	#therefore, although this means a 6x impact on the gdp per dollar spent (money multiplier), i'll make the 
	#formula for calculating gdp this:
	#"""
	#
	## as;dlfkjasd;lkfjasl;kdfja;lskdjf;laksdjf;laksdjf;laksdjf;laksdjf;lkasdjf 
	## anyways 
	## when the dials are at an equilibrium satee, there's no policy pressure so we have to calculate how much the dial is changed compared to the equilibrium levels 
	#var spending_gap = dial_spending - eq_dial_spending 
	#var taxes_gap = dial_taxes - eq_dial_taxes 
	#var ior_gap = dial_ior - eq_dial_ior
	#
	## okay in regards to the shocks that happen when dials are caused and stuff
	## since papua new guinea's highly exposed to commodity price swings like gold, copper, and palm oil (as well as other weather events, since it's basicaly on the equator and such) we have some shocks 
	#var supply_shock: float = randf_range(-0.35, 0.35)
	#var demand_shock: float = randf_range(-0.25, 0.25) 
	#var general_randomness: float = randf_range(-0.15, 0.15) # because economies sometimes just... randomly change! a little bit! so there's always a little bit of randomness around 
	#
	#""" 
	#THE FULL EXPLANATION FOR ALL THE VARIABLES AND STUFF IS ON THE GOOGLE DOC 
	#it's titled "papua new guinea disaster response game" 
	#i might link it to the readme too or something like that perhaps ;alsdkjfa;lskdfj
	#"""
	#
	## ----- all the delta gdp components 
	#var delta_gdp_spending = spending_gap * 4.2 # this is how the spending influences gdp 
	#var delta_gdp_tax = -taxes_gap * 3 # how taxes influence the gdp 
	#var delta_gdp_ior = -ior_gap * 1.4 # how interest on reserves rates influences gdp 
	#var delta_gdp_import_leakage = -spending_gap * 1.7 # since papua new guinea instantly loses a lot of its injected money to instnatly spending on imports, we add an improt leakage multiplier 
	## oh my god my spelling is HORRIBLE today 
	#var delta_gdp: float = delta_gdp_spending + delta_gdp_tax + delta_gdp_ior + delta_gdp_import_leakage + demand_shock # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	## ---- okay end
	#
	#
	## --- NOW ITS TIME FOR INFLATION!!!!!!!! 
	#var delta_inflation_demand_pull = spending_gap * 2.6 
	#var delta_inflation_depreciation = spending_gap * 0.7 
	#var delta_inflation_cost_push = taxes_gap * 1.1 
	#var delta_inflation_monetary_tightening = -ior_gap * 3 
	#
	#var delta_inflation = delta_inflation_demand_pull + delta_inflation_depreciation + delta_inflation_cost_push + delta_inflation_monetary_tightening + (supply_shock * 0.55)
	## -- and thats the end of inflation!!! 
	#
	## - so now for unemployment 
	## see what i did there with the numbe of "-"s getting smaller each time 
	## exactly you missed it again
	## im so hilarious 
	## and sleep deprived
	#
	#var delta_unemployment_okun = -delta_gdp * 0.25 
	#var delta_unemployment_stagflation = (inflation_rate - 8) * 0.12
	#var delta_unemployment_job_tightening = ior_gap * 0.85 
	#
	#var delta_unemployment = delta_unemployment_okun + delta_unemployment_stagflation + delta_unemployment_job_tightening + (demand_shock * 0.28)
	#
	## - so now thats it for the unemployment components 
	#
	#
	#
	#
	#
	#
	## -- when you put it all together 
	#gdp = clamp(gdp + delta_gdp * 0.6, -9, 16)
	#inflation_rate = clamp(inflation_rate + delta_inflation * 0.6, -2, 28)
	#unemployment_rate = clamp(unemployment_rate + delta_unemployment * 0.6, 1, 18)
	#
	### these are all the changes (delta) calculated and these are when they're actually applied to the gdp -- THESE ARE ALL ARCHIVED STUFF PLEASE DONT ACTUALLY LOOK AT THEM FOR FORMULAS 
	##var delta_gdp = (dial_spending * 1.4) - (dial_taxes * 1.2) - (dial_ior * 0.8) + background_variance
	##gdp = clamp(gdp + (delta_gdp * 0.5), -10, 15) # change the delta_gdp * 0.5 to whatever best suits this 
	### and also the delta_inflation * 0.5 and delta_unemployment * 0.5 
	##
	##var delta_inflation = (dial_spending * 2) - ((1 - dial_taxes) * 0.8) - (dial_ior * 2.2) + background_variance
	##inflation_rate = clamp(inflation_rate + (delta_inflation * 0.5), -2, 25)
	##
	### unemployment however reacts inversely to gdp growth, so it has its own separate part here 
	##var delta_unemployment = -(delta_gdp * 0.3) + (dial_ior * 0.5) + background_variance
	##unemployment_rate = clamp(unemployment_rate + (delta_unemployment * 0.5), 1, 15)
	##
	### the national reserves amount fluctuates based on taxes and govt 
	##var interest_balance = (dial_taxes * 8) - (dial_spending * 9)
	##national_reserves_amount = clamp(national_reserves_amount + interest_balance, 0, 300)
	##
	### median income will grow w/ a positive gdp but shrink with taxes
	##median_income = clamp(median_income + (delta_gdp * 50) - (dial_taxes * 30), 4000, 20000)
	##
	### public discontent levels respond to bad econ metrics 
	##var discontent_score = (inflation_rate * 0.5) + (unemployment_rate * 1.2) + (dial_taxes * 10) - (gdp * 0.4)
	##public_discontent_levels = clamp(public_discontent_levels + (discontent_score * 0.2), 0, 100)
	#
	#emit_signal("economy_updated") # send signal to UI so that we know elements changed
	#
#signal economy_updated 
	#
	#
