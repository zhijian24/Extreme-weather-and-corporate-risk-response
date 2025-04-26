clear all

cd "D:\OneDrive - University of Edinburgh\PHD\4_Climate and Finance_shared\Stata final use"

use dataset_baseline, clear

global control1 "TPos TNeg PPos PNeg"
global control2 "tmmx tmmn pr tmmx_squ tmmn_squ pr_squ srad srad_squ vap vap_squ vs vs_squ"

* Regression

* Table 2

reghdfe pct_cash TPos TNeg PPos PNeg ${control2}, absorb (i.year i.firm_id) cl( firm_id )
outreg2 using "Table2.xls", replace nocons bdec(3)   keep(TPos TNeg PPos PNeg) addtext(Control, Yes, Year FE, Yes, Firm FE, Yes)

reghdfe pct_cash L1.TPos L1.PNeg L1.TNeg L1.PPos  ${control2}, absorb(i.year i.firm_id) cl(firm_id)
outreg2 using "Table2.xls", append nocons bdec(3)   keep(L1.TPos L1.PNeg L1.TNeg L1.PPos) addtext(Control, Yes, Year FE, Yes, Firm FE, Yes)

reghdfe pct_cash L(0/1).TPos L(0/1).PNeg L(0/1).TNeg L(0/1).PPos  ${control2}, absorb (i.year i.firm_id) cl( firm_id )
outreg2 using "Table2.xls", append nocons bdec(3)   keep(L(0/1).TPos L(0/1).TNeg L(0/1).PPos L(0/1).PNeg) addtext(Control, Yes, Year FE, Yes, Firm FE, Yes)

* Table 3

reghdfe pct_cash TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone TPos TNeg PPos PNeg  ${control2} ,absorb (i.year i.firm_id) cl(firm_id)
outreg2 using "Table3.xls", replace nocons bdec(3) keep(TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone) addtext(Control, Yes, Year FE, Yes, Firm FE, Yes)

reghdfe pct_cash TPos_lag2_TNone TNeg_lag2_TNone PPos_lag2_PNone PNeg_lag2_PNone L(0/1).TPos L(0/1).TNeg L(0/1).PPos L(0/1).PNeg  ${control2},absorb(i.year i.firm_id) cl( firm_id )
outreg2 using "Table3.xls", append nocons bdec(3) keep(TPos_lag2_TNone TNeg_lag2_TNone PPos_lag2_PNone PNeg_lag2_PNone) addtext(Control, Yes, Year FE, Yes, Firm FE, Yes)

reghdfe pct_cash TPos_lag3_TNone TNeg_lag3_TNone PPos_lag3_PNone PNeg_lag3_PNone L(0/2).TPos L(0/2).TNeg L(0/2).PPos L(0/2).PNeg  ${control2},absorb(i.year i.firm_id) cl( firm_id )
outreg2 using "Table3.xls", append nocons bdec(3) keep(TPos_lag3_TNone TNeg_lag3_TNone PPos_lag3_PNone PNeg_lag3_PNone) addtext(Control, Yes, Year FE, Yes, Firm FE, Yes)

reghdfe pct_cash TPos_lag4_TNone TNeg_lag4_TNone PPos_lag4_PNone PNeg_lag4_PNone L(0/3).TPos L(0/3).TNeg L(0/3).PPos L(0/3).PNeg  ${control2},absorb(i.year i.firm_id) cl( firm_id )
outreg2 using "Table3.xls", append nocons bdec(3) keep(TPos_lag4_TNone TNeg_lag4_TNone PPos_lag4_PNone PNeg_lag4_PNone) addtext(Control, Yes, Year FE, Yes, Firm FE, Yes)

* Table 4

reghdfe change_in_marketcap change_in_cash_ratio change_in_interests change_in_dividends change_in_net_assets change_in_RD market_leverage new_financing cash_lag, absorb(i.year i.firm_id) cl( firm_id )
outreg2 using "Table4.xls", replace nocons bdec(3) keep(change_in_cash_ratio) addtext(Controls, Yes, Year FE, Yes, Firm FE, Yes)

reghdfe change_in_marketcap change_in_cash_ratio c.TPos_lag_TNone#c.change_in_cash_ratio c.TNeg_lag_TNone#c.change_in_cash_ratio c.PPos_lag_PNone#c.change_in_cash_ratio c.PNeg_lag_PNone#c.change_in_cash_ratio change_in_interests change_in_dividends change_in_net_assets change_in_RD market_leverage new_financing cash_lag, absorb(i.year i.firm_id) cl( firm_id )
outreg2 using "Table4.xls", append nocons bdec(3) keep(change_in_cash_ratio c.TPos_lag_TNone#c.change_in_cash_ratio c.TNeg_lag_TNone#c.change_in_cash_ratio c.PPos_lag_PNone#c.change_in_cash_ratio c.PNeg_lag_PNone#c.change_in_cash_ratio) addtext(Controls, Yes, Year FE, Yes, Firm FE, Yes)

* Table 5
* 1st: attention to extreme weather
gen term = 0
replace term = 1 if Extreme_weather > 0.1

gen tt1 = TPos_lag_TNone*term
gen tt2 = TNeg_lag_TNone*term
gen tt3 = PPos_lag_PNone*term
gen tt4 = PNeg_lag_PNone*term

reghdfe pct_cash tt1  TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone ${control1} ${control2}, absorb (i.year i.firm_id) cl( firm_id )
outreg2 using "Table5.xls", replace nocons bdec(3) keep(tt1  TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone ) addtext(Controls, Yes, Year FE, Yes, Firm FE, Yes)  

reghdfe pct_cash tt2  TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone ${control1} ${control2}, absorb (i.year i.firm_id) cl( firm_id )
outreg2 using "Table5.xls", append nocons bdec(3) keep(tt2  TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone) addtext(Controls, Yes, Year FE, Yes, Firm FE, Yes)   

reghdfe pct_cash tt3  TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone ${control1} ${control2}, absorb (i.year i.firm_id) cl( firm_id )
outreg2 using "Table5.xls", append nocons bdec(3) keep(tt3  TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone) addtext(Controls, Yes, Year FE, Yes, Firm FE, Yes) 

reghdfe pct_cash tt4  TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone ${control1} ${control2}, absorb (i.year i.firm_id) cl( firm_id )
outreg2 using "Table5.xls", append nocons bdec(3) keep(tt4  TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone) addtext(Controls, Yes, Year FE, Yes, Firm FE, Yes) 

* 2nd: attention to climate change
drop term tt1 tt2 tt3 tt4
gen term = 0
replace term = 1 if Climate_change > 7.75

gen tt1 = TPos_lag_TNone*term
gen tt2 = TNeg_lag_TNone*term
gen tt3 = PPos_lag_PNone*term
gen tt4 = PNeg_lag_PNone*term

reghdfe pct_cash tt1  TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone ${control1} ${control2}, absorb (i.year i.firm_id) cl( firm_id )
outreg2 using "Table5.xls", append nocons bdec(3) keep(tt1  TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone) addtext(Controls, Yes, Year FE, Yes, Firm FE, Yes)  

reghdfe pct_cash tt2  TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone ${control1} ${control2}, absorb (i.year i.firm_id) cl( firm_id )
outreg2 using "Table5.xls", append nocons bdec(3) keep(tt2  TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone) addtext(Controls, Yes, Year FE, Yes, Firm FE, Yes)  

reghdfe pct_cash tt3  TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone ${control1} ${control2}, absorb (i.year i.firm_id) cl( firm_id )
outreg2 using "Table5.xls", append nocons bdec(3) keep(tt3  TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone) addtext(Controls, Yes, Year FE, Yes, Firm FE, Yes) 

reghdfe pct_cash tt4  TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone ${control1} ${control2}, absorb (i.year i.firm_id) cl( firm_id )
outreg2 using "Table5.xls", append nocons bdec(3) keep(tt4  TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone) addtext(Controls, Yes, Year FE, Yes, Firm FE, Yes) 

* 3rd: attention to climate risk
drop term tt1 tt2 tt3 tt4
gen term = 0
replace term = 1 if  Climate_risk > 0

gen tt1 = TPos_lag_TNone*term
gen tt2 = TNeg_lag_TNone*term
gen tt3 = PPos_lag_PNone*term
gen tt4 = PNeg_lag_PNone*term

reghdfe pct_cash tt1  TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone ${control1} ${control2}, absorb (i.year i.firm_id) cl( firm_id )
outreg2 using "Table5.xls", append nocons bdec(3) keep(tt1  TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone) addtext(Controls, Yes, Year FE, Yes, Firm FE, Yes)  

reghdfe pct_cash tt2  TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone ${control1} ${control2}, absorb (i.year i.firm_id) cl( firm_id )
outreg2 using "Table5.xls", append nocons bdec(3) keep(tt2  TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone) addtext(Controls, Yes, Year FE, Yes, Firm FE, Yes)  

reghdfe pct_cash tt3  TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone ${control1} ${control2}, absorb (i.year i.firm_id) cl( firm_id )
outreg2 using "Table5.xls", append nocons bdec(3) keep(tt3  TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone) addtext(Controls, Yes, Year FE, Yes, Firm FE, Yes) 

reghdfe pct_cash tt4  TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone ${control1} ${control2}, absorb (i.year i.firm_id) cl( firm_id )
outreg2 using "Table5.xls", append nocons bdec(3) keep(tt4  TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone) addtext(Controls, Yes, Year FE, Yes, Firm FE, Yes)  

* 4th: attention to droughts
drop term tt4
gen term = 0
replace term = 1 if  droughts > 0.1
gen tt4 = PNeg_lag_PNone*term

reghdfe pct_cash tt4  TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone ${control1} ${control2}, absorb (i.year i.firm_id) cl( firm_id )
outreg2 using "Table5.xls", append nocons bdec(3) keep(tt4  TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone) addtext(Controls, Yes, Year FE, Yes, Firm FE, Yes)  

* 5th: attention to extreme heat
drop term tt1
gen term = 0
replace term = 1 if  extreme_heat > 0
gen tt1 = TPos_lag_TNone*term

reghdfe pct_cash tt1  TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone ${control1} ${control2}, absorb (i.year i.firm_id) cl( firm_id )
outreg2 using "Table5.xls", append nocons bdec(3) keep(tt1  TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone) addtext(Controls, Yes, Year FE, Yes, Firm FE, Yes)  

* Table 6

gen interact3_1 = within200km_coast * TPos_lag_TNone
gen interact3_2 = within200km_coast * TNeg_lag_TNone
gen interact3_3 = within200km_coast * PPos_lag_PNone
gen interact3_4 = within200km_coast * PNeg_lag_PNone

reghdfe pct_cash interact3_1 TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone ${control1} ${control2} , absorb (i.year i.firm_id) cl( firm_id )
outreg2 using "Table6.xls", replace nocons bdec(3) keep(interact3_1 TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone) addtext(Controls, Yes, Year FE, Yes, Firm FE, Yes)   

reghdfe pct_cash interact3_2 TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone ${control1} ${control2} , absorb (i.year i.firm_id) cl( firm_id )
outreg2 using "Table6.xls", append nocons bdec(3) keep(interact3_2 TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone) addtext(Controls, Yes, Year FE, Yes, Firm FE, Yes)   

reghdfe pct_cash interact3_3 TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone ${control1} ${control2} , absorb (i.year i.firm_id) cl( firm_id )
outreg2 using "Table6.xls", append nocons bdec(3) keep(interact3_3 TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone) addtext(Controls, Yes, Year FE, Yes, Firm FE, Yes)  

reghdfe pct_cash interact3_4 TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone ${control1} ${control2} , absorb (i.year i.firm_id) cl( firm_id )
outreg2 using "Table6.xls", append nocons bdec(3) keep(interact3_4 TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone) addtext(Controls, Yes, Year FE, Yes, Firm FE, Yes)   

* Table 7
reghdfe pct_cash TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone TPos TNeg PPos PNeg  ${control2} ,absorb (i.year i.firm_id) cl(firm_id)
outreg2 using "Table7.xls", replace nocons bdec(3) keep(TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone) addtext(Control, Yes, Year FE, Yes, Firm FE, Yes)

reghdfe pct_cash TPos_lag_TNone2 TNeg_lag_TNone2 PPos_lag_PNone2 PNeg_lag_PNone2 tmmx_pos_num_10_90 tmmn_neg_num_10_90 pr_pos_num_10_90 pr_neg_num_10_90  ${control2},absorb (i.year i.firm_id) cl( firm_id )
outreg2 using "Table7.xls", append nocons bdec(3) keep(TPos_lag_TNone2 TNeg_lag_TNone2 PPos_lag_PNone2 PNeg_lag_PNone2) addtext(Control, Yes, Year FE, Yes, Firm FE, Yes)

reghdfe pct_cash TPos_lag_TNone4 TNeg_lag_TNone4 PPos_lag_PNone4 PNeg_lag_PNone4 TPos TNeg PPos PNeg ${control2},absorb (i.year i.firm_id) cl( firm_id )
outreg2 using "Table7.xls", append nocons bdec(3) keep(TPos_lag_TNone4 TNeg_lag_TNone4 PPos_lag_PNone4 PNeg_lag_PNone4) addtext(Control, Yes, Year FE, Yes, Firm FE, Yes) 

reghdfe pct_total_CSTI TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone ${control1} ${control2}, absorb(i.year i.firm_id) cl( firm_id )
outreg2 using "Table7.xls", append nocons bdec(3) keep(TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone) addtext(Control, Yes, Year FE, Yes, Firm FE, Yes) 

reghdfe pct_cash TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone TPos TNeg PPos PNeg  ${control2} ,absorb (i.year i.firm_id) cl( grid )
outreg2 using "Table7.xls", append nocons bdec(3)  keep(TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone) addtext(Control, Yes, Year FE, Yes, Firm FE, Yes)

gen subsample1 = 0
replace subsample1 = 1 if total_employees <= 1000 

reghdfe pct_cash TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone ${control1} ${control2} if subsample1 == 1, absorb(i.year i.firm_id) cl( firm_id )
outreg2 using "Table7.xls", append nocons bdec(3)  keep(TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone) addtext(Control, Yes, Year FE, Yes, Firm FE, Yes)

reghdfe pct_cash TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone ${control1} ${control2} change_in_interests change_in_dividends change_in_net_assets change_in_RD market_leverage new_financing cash_lag, absorb (i.year i.firm_id) cl( firm_id )
outreg2 using "Table7.xls", append nocons bdec(3) keep(TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone) addtext(Control, Yes, Year FE, Yes, Firm FE, Yes) 

gen paris = 0
replace paris = 1 if year >=2017
reghdfe pct_cash TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone paris ${control1} ${control2} , absorb(i.year i.firm_id) cl( firm_id )
outreg2 using "Table7.xls", append nocons bdec(3)  keep(TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone) addtext(Control, Yes, Year FE, Yes, Firm FE, Yes)

* Table 8

reghdfe pct_cash TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone TPos TNeg PPos PNeg  ${control2} if sensitive_rain == 1,absorb (i.year i.firm_id) cl(firm_id)
outreg2 using "Table8.xls", replace nocons bdec(3) keep(TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone ) addtext(Controls, Yes, Year FE, Yes, Firm FE, Yes)   

reghdfe pct_cash TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone TPos TNeg PPos PNeg  ${control2} if sensitive_rain == 0,absorb (i.year i.firm_id) cl(firm_id)
outreg2 using "Table8.xls", append nocons bdec(3) keep(TPos_lag_TNone TNeg_lag_TNone PPos_lag_PNone PNeg_lag_PNone )  addtext(Controls, Yes, Year FE, Yes, Firm FE, Yes)   