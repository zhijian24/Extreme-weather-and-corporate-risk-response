set more off
pause off

// Define global paths for data directories
global root      = "C:\Users\yuzhi\OneDrive\Climate_and_firms\Data"
global rawdata   = "$root/rawdata"
// global dofiles     = "$root/dofiles" // Not used in this script, can be commented out or removed
global temp_data = "$root/temp_data"
// global results   = "$root/results" // Not explicitly used for saving here, but good practice

// Load the base dataset
use "$temp_data/dataset_use.dta", clear

// --- Sample Restriction and Basic Setup ---

// Generate regional identifier (used for sample restriction only)
gen county_id = 0
// Label for the regional identifier
label variable county_id "1=Africa; 2=India; 3=China; 4=Nordics; 5=USA"
replace county_id = 1 if inlist(country, "Algeria", "Benin", "Botswana", "Burkina Faso", "Egypt")
replace county_id = 1 if inlist(country, "Libya", "Malawi", "Mali", "Mauritius", "Morocco")
replace county_id = 1 if inlist(country, "South Africa", "Sudan", "Swaziland", "Tanzania")
replace county_id = 1 if inlist(country, "Gabon", "Gambia", "Ghana", "Ivory Coast", "Kenya")
replace county_id = 1 if inlist(country, "Namibia", "Niger", "Nigeria", "Rwanda", "Senegal")
replace county_id = 1 if inlist(country, "Togo", "Tunisia", "Uganda", "Zambia", "Zimbabwe")
replace county_id = 2 if inlist(country, "India")
replace county_id = 3 if inlist(country, "China")
replace county_id = 4 if inlist(country, "Denmark", "Finland", "Iceland", "Norway", "Sweden")
replace county_id = 5 if inlist(country, "United States")
drop if county_id == 0 // Restrict sample to specified regions
drop county_id // Drop identifier after use, as it's not a feature

// Generate grouping variables (needed for sorting/panel operations)
egen industrygroup = group(sic)
egen countrygroup = group(country)
encode ExcelCompanyID, gen(firm_id) // Needed for xtset and merge

// 1. Exclude finance and related industries based on SIC codes
drop if missing(sic) // Drop if SIC code is missing
local finance_sic "6020 6021 6022 6035 6140 6141 6159 6162 6211 6221 6231 6280 6282 6299 6311 6321 6331 6351 6361 6371 6399 6411 6500 6510 6512 6552 6722 6726 6798"
foreach code of local finance_sic {
    drop if sic == "`code'"
}

// 2. Winsorize raw variables needed DIRECTLY as features or as INPUTS for constructed features/target
// List includes variables from the python 'features' list + inputs for calculated features/target (_w versions created by winsor2 assumed OK if base name in features)
winsor2 CapitalExpenditure CASH_EQV TotalRevenue Total_assest RDE EBTIDA PayoutRatio ni currentasset currentliability lt_invest lt_debt nppe interest_exp extraordinary_items_ffiec lt_debt_issued st_debt net_stocks_reported_private cash_acquire_cf common_rep pref_rep net_debt_issued change_net_working_capital total_debt_issued st_debt_issued full_time part_time total_employees employees_under_uc pderp avg_temp_employees paec marketcap CashFromOps, cut(1 99) replace // Added 'replace'

// --- Data Cleaning & Merging ---

// Clean avg_temp_employees (feature) - Use the winsorized version created above
replace avg_temp_employees_w = . if avg_temp_employees_w < 0

// Drop observations with zero or missing assets after winsorization (essential for ratios)
drop if Total_assest_w == 0 | missing(Total_assest_w)

// Merge Total Liability (needed for net_asset calculation)
// Using preserve/restore to ensure merge key uniqueness in memory before merge
preserve
keep ExcelCompanyID year
duplicates drop ExcelCompanyID year, force
tempfile unique_ids
save `unique_ids'
restore
merge 1:1 ExcelCompanyID year using "$rawdata/dataset_Y_Total_liablity.dta", keepusing(Total_liablity) // Only keep necessary variable
drop if _merge == 2 // Drop master observations without matching liability data
drop _merge

// --- Feature Engineering ---

// Calculate Net Asset (Foundation for several features/target)
gen net_asset = Total_assest_w - Total_liablity // Use winsorized assets
drop if net_asset <= 0 | missing(net_asset) // Ratios require positive net assets

// Calculate base variable for target 'cash_a_w'
// Assuming 'cash_a_w' is the winsorized version of this logged ratio 'cash_a'
gen cash_a = ln((CASH_EQV_w / net_asset) * 100) // Use winsorized cash
label variable cash_a "Log of Cash & Equivalents to Net Asset Ratio (%)"

// Set up panel structure for lags and within-entity calculations
sort firm_id year
xtset firm_id year

// Generate lags and stats of cash_a (needed for features) - calculated BEFORE winsorizing cash_a itself
gen cash_a_lag1 = L1.cash_a
gen cash_a_lag2 = L2.cash_a
gen cash_a_lag3 = L3.cash_a

bys firm_id: egen mean_cash_a = mean(cash_a) // Within-firm mean over available history
bys firm_id: egen max_cash_a = max(cash_a)   // Within-firm max over available history
bys firm_id: egen min_cash_a = min(cash_a)   // Within-firm min over available history
// Features list requested these specific names

// Calculate other base variables for features (will be winsorized later)
gen CF = EBTIDA_w / net_asset * 100
label variable CF "Cash Flow (EBITDA / Net Asset) %"

gen leverage = (lt_debt_w + st_debt_w) / net_asset * 100
label variable leverage "Leverage (Total Debt / Net Asset) %"

gen market_value_of_asset = marketcap_w + lt_debt_w + st_debt_w - CASH_EQV_w
gen MTB = market_value_of_asset / Total_assest_w * 100
label variable MTB "Market-to-Book Ratio (%)"

gen size = ln(net_asset)
label variable size "Log of Net Assets"

gen NWC_use = (currentasset_w - currentliability_w) / net_asset * 100
label variable NWC_use "Net Working Capital to Net Asset Ratio (%)"

gen CAPEX = CapitalExpenditure_w / net_asset * 100
label variable CAPEX "Capital Expenditure to Net Asset Ratio (%)"

// Calculate total dividends to create binary DIV indicator
gen total_dividends = PayoutRatio_w * ni_w // Use winsorized inputs
gen DIV = (total_dividends > 0 & !missing(total_dividends)) // Binary indicator, handle missing
label variable DIV "Dividend Payer Dummy (1 if paid)"

gen RD_use = RDE_w / TotalRevenue_w * 100 // Use winsorized RDE and Revenue
label variable RD_use "R&D Expense to Total Revenue Ratio (%)"

// Calculate Industry Sigma (INDSIG) - measure of industry cash flow volatility
gen Free_cash_flow = CashFromOps_w - CapitalExpenditure_w // Intermediate calculation
gen sic2 = substr(sic, 1, 2) // Get 2-digit SIC
replace sic2 = "." if sic2 == "-" | sic2 == "" | missing(sic2) // Clean sic2
destring sic2, replace force // Convert sic2 to numeric, forcing non-numeric to missing

bys sic2: egen cashflow_sd = sd(Free_cash_flow) // Calculate std dev of FCF within industry
gen ratio_for_indsig = cashflow_sd / Total_assest_w * 100 // Ratio for INDSIG calc
bys sic2: egen INDSIG = mean(ratio_for_indsig) // Calculate mean of the ratio within industry
label variable INDSIG "Industry Cash Flow Volatility (Mean of Firm SD(FCF)/Asset)"
drop Free_cash_flow cashflow_sd ratio_for_indsig // Clean up intermediates

// Merge Industry Regulation Info (needed for REG feature)
merge m:1 sic2 using "$rawdata/dataset_industry.dta", keepusing(regulated_industry)
drop if _merge == 2
drop _merge
gen REG = regulated_industry // Base variable for REG_w feature
label variable REG "Regulated Industry Dummy"

// Merge Country Identifiers and Global Variables (needed for features)
merge m:1 country using "$rawdata/dataset_global_short.dta", keepusing(country_short)
drop if _merge == 2
drop _merge

merge m:1 country_short year using "$rawdata/dataset_global.dta", keepusing(legal_index total_tax_rate risk_premium interest_rate inflation GDP_rate aGDP GDP)
drop if _merge == 2
drop _merge

// Merge Management/Board Variables (needed for features)
merge 1:1 ExcelCompanyID year using "$rawdata/dataset_Y_add_management.dta", keepusing(max_board_size min_board_size aiot poos)
drop if _merge == 2
drop _merge

// --- Final Winsorization ---

// Winsorize variables that are features themselves (board/global/management)
// This creates the final _w versions needed based on python features list naming convention
winsor2 max_board_size min_board_size aiot poos legal_index total_tax_rate risk_premium interest_rate inflation GDP_rate aGDP GDP, cut(1 99) replace

// Winsorize the calculated financial ratios and indicators (creates final features and target)
// This creates the final _w versions listed in the Python features list, including the target cash_a_w
winsor2 cash_a CF leverage MTB size NWC_use CAPEX DIV RD_use REG INDSIG, cut(1 99) replace

// --- Final Cleanup ---

// Remove intermediate variables not needed as features (base versions etc.)
drop Total_liablity net_asset cash_a CF leverage market_value_of_asset MTB size NWC_use CAPEX total_dividends DIV RD_use sic2 regulated_industry country_short INDSIG REG industrygroup countrygroup

// Remove other variables not listed in the final features list or target
// Note: Original winsorized variables (e.g., TotalRevenue_w, RDE_w) are kept as they are listed as features

di "Finished data preparation. Dataset contains target 'cash_a_w' and specified features."