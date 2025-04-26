clear all

global root     = "D:\OneDrive - University of Edinburgh\PHD\4_Climate and Finance_shared\stata" 
global rawdata     = "$root/rawdata"
global dofiles      = "$root/dofiles"
global temp_data    = "$root/temp_data"
global results = "$root/results/results_0309"

use "$temp_data/dataset_use_final.dta",  clear

gen tmmx_squ = tmmx*tmmx
gen tmmn_squ = tmmn*tmmn
gen pr_squ = pr*pr



gen TNum = tmmx_pos_num + tmmn_neg_num2
gen PNum = pr_pos_num + pr_neg_num
gen TNone = 0 
replace TNone = 1 if tmmx_pos_num == 0 & tmmn_neg_num2 == 0
gen PNone = 0
replace PNone = 1 if pr_neg_num == 0 & pr_pos_num == 0

xtset firm_id year 
gen T_lag_TNone = L1.TNum #TNone
gen P_lag_PNone = L1.PNum #PNone

xtset firm_id year 
gen TPos_lag_TNone = L1.tmmx_pos_num #TNone
gen TNeg_lag_TNone = L1.tmmn_neg_num2 #TNone
gen PPos_lag_PNone = L1.pr_pos_num #PNone
gen PNeg_lag_PNone = L1.pr_neg_num #PNone

gen TNone_L1 = 0 
replace TNone_L1 = 1 if L1.tmmx_pos_num == 0 & L1.tmmn_neg_num2 == 0
gen PNone_L1 = 0
replace PNone_L1 = 1 if L1.pr_neg_num == 0 & L1.pr_pos_num == 0
gen TPos_lag2_TNone = L2.tmmx_pos_num #TNone #TNone_L1
gen TNeg_lag2_TNone = L2.tmmn_neg_num2 #TNone #TNone_L1
gen PPos_lag2_PNone = L2.pr_pos_num #PNone #PNone_L1
gen PNeg_lag2_PNone = L2.pr_neg_num #PNone #PNone_L1

gen TNone_L2 = 0 
replace TNone_L2 = 1 if L2.tmmx_pos_num == 0 & L2.tmmn_neg_num2 == 0
gen PNone_L2 = 0
replace PNone_L2 = 1 if L2.pr_neg_num == 0 & L2.pr_pos_num == 0
gen TPos_lag3_TNone = L3.tmmx_pos_num #TNone #TNone_L1 #TNone_L2
gen TNeg_lag3_TNone = L3.tmmn_neg_num2 #TNone #TNone_L1 #TNone_L2
gen PPos_lag3_PNone = L3.pr_pos_num #PNone #PNone_L1 #PNone_L2
gen PNeg_lag3_PNone = L3.pr_neg_num #PNone #PNone_L1 #PNone_L2

gen TNone_L3 = 0 
replace TNone_L3 = 1 if L3.tmmx_pos_num == 0 & L3.tmmn_neg_num2 == 0
gen PNone_L3 = 0
replace PNone_L3 = 1 if L3.pr_neg_num == 0 & L3.pr_pos_num == 0
gen TPos_lag4_TNone = L4.tmmx_pos_num #TNone #TNone_L1 #TNone_L2 #TNone_L3
gen TNeg_lag4_TNone = L4.tmmn_neg_num2 #TNone #TNone_L1 #TNone_L2 #TNone_L3
gen PPos_lag4_PNone = L4.pr_pos_num #PNone #PNone_L1 #PNone_L2 #PNone_L3
gen PNeg_lag4_PNone = L4.pr_neg_num #PNone #PNone_L1 #PNone_L2 #PNone_L3

merge m:1 country  using "$rawdata/country_isocode"
drop if _merge == 2
drop _merge

merge m:1 isocode year using "$rawdata/google_trends_country"
drop if _merge == 2
drop _merge 

merge m:1 ExcelCompanyID using "$temp_data/firm_within_200km_coast"
drop if _merge == 2

gen within200km_coast = 0
replace within200km_coast = 1 if _merge == 3

drop _merge

xtset firm_id year
gen TPos_None = 1 if TPos_lag_TNone > 0
replace TPos_None = 0 if TPos_None==.
gen TNeg_None = 1 if TNeg_lag_TNone > 0
replace TNeg_None = 0 if TNeg_None==.
gen PPos_None = 1 if PPos_lag_PNone > 0
replace PPos_None = 0 if PPos_None==.
gen PNeg_None = 1 if PNeg_lag_PNone > 0
replace PNeg_None = 0 if PNeg_None==.

sort firm_id year

gen cash_lag = L1.CASH_EQV_w

gen change_in_cash = CASH_EQV_w - cash_lag

gen marketcap_lag = L1.marketcap

gen change_in_cash_ratio = change_in_cash / marketcap_lag *100

gen change_in_marketcap = (marketcap - marketcap_lag) / marketcap_lag*100

*gen change_in_marketcap2 = marketcap - marketcap_lag

gen change_in_interests = (interest_exp - L1.interest_exp) / marketcap_lag*100

gen change_in_dividends = (total_dividends - L1.total_dividends) / marketcap_lag*100

gen net_assest = Total_assest- CASH_EQV

gen change_in_net_assets = (net_assest - L1.net_assest) / marketcap_lag*100

gen change_in_RD = (RDE - L1.RDE) / marketcap_lag

gen market_leverage = (st_debt + lt_debt) / (st_debt + lt_debt + marketcap) *100

rename tmmx_pos_num TPos
rename tmmn_neg_num2 TNeg
rename pr_pos_num PPos
rename pr_neg_num PNeg

merge m:1 sic using "$rawdata/sensitive_rain_industry" 
rename excess rain_excess
rename deficit rain_deficit
replace rain_excess = 0 if rain_excess == .
replace rain_deficit = 0 if rain_deficit == .
gen sensitive_rain = 0
replace sensitive_rain = 1 if rain_excess == 1 | rain_deficit == 1
drop _merge

*****
merge m:1 grid year using "$rawdata/dataset_climate_robust.dta"
drop if _merge == 2
drop _merge

gen TNone2 = 0 
replace TNone2 = 1 if tmmx_pos_num_10_90 == 0 & tmmn_neg_num_10_90 == 0
gen PNone2 = 0
replace PNone2 = 1 if pr_neg_num_10_90 == 0 & pr_pos_num_10_90 == 0

xtset firm_id year 
gen TPos_lag_TNone2 = L1.tmmx_pos_num_10_90 #TNone2
gen TNeg_lag_TNone2 = L1.tmmn_neg_num_10_90 #TNone2
gen PPos_lag_PNone2 = L1.pr_pos_num_10_90 #PNone2
gen PNeg_lag_PNone2 = L1.pr_neg_num_10_90 #PNone2

gen TNone4 = 0 
replace TNone4 = 1 if tmmn_negative_sum == 0 & tmmx_positive_sum == 0
gen PNone4 = 0
replace PNone4 = 1 if pr_positive_sum == 0 & pr_negative_sum == 0

xtset firm_id year 
gen TPos_lag_TNone4 = L1.tmmx_positive_sum #TNone4
gen TNeg_lag_TNone4 = L1.tmmn_negative_sum #TNone4
gen PPos_lag_PNone4 = L1.pr_positive_sum #PNone4
gen PNeg_lag_PNone4 = L1.pr_negative_sum #PNone4
replace TNeg_lag_TNone4 = TNeg_lag_TNone4*(-1)
replace PNeg_lag_PNone4 =  PNeg_lag_PNone4*(-1)

save "D:\OneDrive - University of Edinburgh\PHD\4_Climate and Finance_shared\Stata final use/dataset_baseline", replace