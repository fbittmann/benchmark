*! version 1.0 22apr2024	Felix Bittmann
cap program drop benchmark
program define benchmark
	syntax [, scale(real 1.0) graph SINGLEthread]
	
	if "`singlethread'" == "singlethread" {
		set processors 1
	}
	
	di "Benchmark started..."
	*** Data generation ***
	timer clear 5
	timer on 5
	local run = round(700 * `scale')
	forvalues i = 1 / `run' {
		clear
		qui set obs 5000
		forvalues j = 1 / 500 {
			gen vara`j' = rnormal()
			gen varb`j' = runiform()
		}
	}
	timer off 5
	qui timer list 5
	local runtime_1 = round(r(t5))
	di "Module 1/8 finished..."	
	
	
	*** Bootstrapping + Regress ***
	timer clear 5
	timer on 5
	local run = round(6000 * `scale')
	qui sysuse nlsw88, clear
	qui expand 10
	qui reg wage hours tenure age union south ///
		, vce(bootstrap, reps(`run'))
	qui estat bootstrap
	timer off 5
	qui timer list 5
	local runtime_2 = round(r(t5))
	di "Module 2/8 finished..."
	
	
	*** Factor analysis ***
	timer clear 5
	timer on 5
	local run = round(250 * `scale')
	qui sysuse auto, clear
	qui expand 15000
	forvalues i = 1 / `run' {
		qui pca price mpg headroom trunk weight length turn, mineigen(1)
		qui rotate, promax
	}
	timer off 5
	qui timer list 5
	local runtime_3 = round(r(t5))
	di "Module 3/8 finished..."
	
	
	*** Read/Write ***
	timer clear 5
	timer on 5
	qui sysuse auto, clear
	qui expand 15000
	qui save "tempfile766374348.dta", replace
	local run = round(850 * `scale')
	forvalues i = 1 / `run' {
		qui use "tempfile766374348.dta", clear
		qui replace price = price + 1
		qui save "tempfile766374348.dta", replace
	}
	cap erase "tempfile766374348.dta"		//Windows
	cap rm "tempfile766374348.dta"		//UNIX
	timer off 5
	qui timer list 5
	local runtime_4 = round(r(t5))
	di "Module 4/8 finished..."
	
	
	*** Imputation ***
	qui sysuse nlsw88, clear
	gen loss1 = runiform()
	gen loss2 = runiform()
	gen loss3 = runiform()
	qui replace race = . if loss1 < 0.10
	qui replace wage = . if loss2 < 0.30
	qui replace grade = . if loss3 < 0.20
	tempfile imp
	qui save `imp', replace
	
	timer clear 5
	timer on 5
	local run = round(10 * `scale')
	forvalues i = 1 / `run' {
		qui use `imp', clear
		mi set flong
		qui mi register imputed race wage grade union south tenure
		qui mi impute chained (pmm, knn(5)) wage tenure ///
			(logit) union ///
			(ologit, ascont) grade ///
			(mlogit) race ///
			= age, add(7) burnin(15) dots
	}
	timer off 5
	qui timer list 5
	local runtime_5 = round(r(t5))
	di "Module 5/8 finished..."
	
	
	*** Multilevel ***
	cap webuse childweight, clear
	if _rc == 0 {
		timer clear 5
		timer on 5
		local run = round(500 * `scale')
		qui expand 10
		forvalues i = 1 / `run' {
			qui mixed weight age girl || id:age
			qui estat icc
		}
		timer off 5
		qui timer list 5
		local runtime_6 = round(r(t5))
		di "Module 6/8 finished..."
	}
	else {
		di as error "Warning! Module Multilevel cannot be run as there is no connection to the internet!"
		local runtime_6 = 0
	}
	
	
	*** SEM ***
	qui sysuse auto, clear
	qui expand 50
	timer clear 5
	timer on 5
	local run = round(50 * `scale')
	forvalues i = 1 / `run' {
		qui gsem (Dim -> trunk weight length turn displacement) ///
			(Dim -> foreign, logit) (Dim -> rep78, ologit)
	}
	timer off 5
	qui timer list 5
	local runtime_7 = round(r(t5))
	di "Module 7/8 finished..."
	
	
	*** DYDX ***
	qui sysuse nlsw88, clear
	qui expand 20
	timer clear 5
	timer on 5
	local run = round(250 * `scale')
	qui logit union grade south smsa c_city wage hours ttl_exp
	forvalues i = 1 / `run' {		
		qui margins, dydx(*)	
	}
	timer off 5
	qui timer list 5
	local runtime_8 = round(r(t5))
	di "Module 8/8 finished..."
	
	
	
	local total = `runtime_1'+`runtime_2'+`runtime_3'+`runtime_4'+`runtime_5' ///
		+`runtime_6'+`runtime_7'+`runtime_8'
	di as result "Results"
	di "Time 1 (Data generation): `runtime_1'"
	di "Time 2 (Bootstrapping): `runtime_2'"
	di "Time 3 (PCA): `runtime_3'"
	di "Time 4 (R/W): `runtime_4'"
	di "Time 5 (Imputation): `runtime_5'"
	di "Time 6 (Multilevel): `runtime_6'"
	di "Time 7 (SEM): `runtime_7'"
	di "Time 8 (DYDX): `runtime_8'"
	di "Total time: `total'"
	
	
	*** Graphing ***
	if "`graph'" == "graph" {
		clear
		qui set obs 1
		forvalues i = 1 / 8 {
			gen x`i' = `runtime_`i''
		}
		graph bar x*, legend(order(1 "Data gen" 2 "BS" 3 "PCA" 4 "R/W" 5 "MICE" ///
			6 "ML" 7 "SEM" 8 "DYDX") row(2)) blabel(bar) ///
			note("Total = `total' sec / Scaling = `scale' `singlethread'") ///
			ytitle("Runtime [sec]")
	}
	
	
	if "`singlethread'" == "singlethread" {
		di as error "Warning! The number of threads to use has been set to 1!"
		di as error "To use all available threads for subsequent computations, restart Stata now!"
		}
	clear
end


*benchmark, graph scale(0.5) single


