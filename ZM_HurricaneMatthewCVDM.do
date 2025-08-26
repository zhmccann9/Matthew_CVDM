clear
cd "C:\Users\zmccann\OneDrive - Emory University\Desktop\Matthew Redux"
use "analytic_data_matt_bach"
set scheme s2mono

egen matthew = anymatch(fips), v(12095 13229 13267 37069 13251 13279 12097 ///
51175 12069 45055 13025 13107 12007 51093 12111 12099 12019 13043 13165 ///
13299 13109 37185 12011 12085 51620 45079 45049 13039 12009 12031 ///
12035 12089 12107 12109 12117 /// 
12127 13029 13031 13051 13103 13127 13179 13183 13191 13305 37007 ///
37013 37015 37017 37019 37029 37031 37037 37041 37047 37049 37051 37053 ///
37055 37061 37063 37065 37073 37079 37083 37085 37091 37093 37095 37101 ///
37103 37105 37107 37117 37125 37127 37129 37131 37133 37135 37137 37139 ///
37141 37143 37147 37153 37155 37163 37165 37177 37183 37187 37191 37195 ///
45005 45009 45013 45015 45017 45019 45025 45027 45029 45031 45033 45035 ///
45041 45043 45051 45061 45067 45069 45075 45085 45089 51550 51800 51810)
 
egen hd = anymatch(fips), v(12009 12031 12035 12089 12107 12109 12117 /// 
12127 13029 13031 13051 13103 13109 13127 13179 13183 13191 13305 37007 ///
37013 37015 37017 37019 37029 37031 37037 37041 37047 37049 37051 37053 ///
37055 37061 37063 37065 37073 37079 37083 37085 37091 37093 37095 37101 ///
37103 37105 37107 37117 37125 37127 37129 37131 37133 37135 37137 37139 ///
37141 37143 37147 37153 37155 37163 37165 37177 37183 37187 37191 37195 ///
45005 45009 45013 45015 45017 45019 45025 45027 45029 45031 45033 45035 ///
45041 45043 45051 45061 45067 45069 45075 45085 45089 51550 51800 51810)
 
 
egen ld = anymatch(fips), v(12095 13229 13267 37069 13251 13279 12097 ///
51175 12069 45055 13025 13107 12007 51093 12111 12099 12019 13043 13165 ///
13299 37185 12011 12085 51620 45079 45049 13039) 

replace hid18 = 1 if ld == 1
replace hid18 = 2 if hd == 1

tab matthew hd
tab matthew ld
 
drop meancvdm
drop bus*
drop yrmonth


gen ab13 = grant13+adv13
gen ab14 = grant14+adv14
gen ab15 = grant15+adv15
gen ab16 = grant16+adv16
gen ab17 = grant17+adv17
gen ab18 = grant18+adv18

gen npf = np+ab13 if year == 2013
replace npf = np+ab14 if year == 2014
replace npf = np+ab15 if year == 2015
replace npf = np+ab16 if year == 2016
replace npf = np+ab17 if year == 2017
replace npf = np+ab18 if year == 2018


sort fips year month

*DV*
egen meancvdm = mean(cvdmort_rte), by(year month hid18)


*fam unity*
gen inv_sin = 1 -(sinp)
replace inv_sin = inv_sin*100

gen inv_unb = 100 - (unbir)	
tab1 inv_sin inv_unb

*institutional conf
gen pvote12 = totalvotes2012/pop12_18
gen pvote16 = totalvotes2012/pop16_18
gen pavt = (pvote12 + pvote16)/2

*informciv
gen np10k = npf/(pop/(10000))
tab np10k

gen rel10k = rel/(pop/(10000))
tab rel10k

*collective efficacy
egen pop13 = mean(pop) if year == 2013, by(fips)
egen pop13a = mean(pop13), by(fips)
egen pop14 = mean(pop) if year == 2014, by(fips)
egen pop14a = mean(pop14), by(fips)

egen vc13 = mean(vc) if year == 2013, by(fips)
egen vc14 = mean(vc) if year == 2014, by(fips)
egen vc13a = mean(vc13), by (fips)
egen vc14a = mean(vc14), by (fips)

gen vcr12 = (violentcrimecount2012/totalpopulation2012)*100000
gen vcr13 = (vc13a/pop13a)*100000
gen vcr14 = (vc14a/pop14a)*100000

gen vc1718 = ((vcr12+vcr13+vcr14)/3)
replace vc = vc1718 if year == 2017
replace vc = vc1718 if year == 2018


tab vc
gen vcr = (vc/pop)*100000



*control*
gen loginc = log(inc)





*time*
gen double date = ym(year, month)
format date %tm
drop if date < tm(2013m1)


**Generating time intervals**
gen mo6 = .
replace mo6 = 1 if date == tm(2017april)

gen yr1 = .
replace yr1 = 1 if date == tm(2017oct)

gen final = .
replace final = 1 if date == tm(2018december)





	
**Declare global SC var and loop**
global socap vcr ///
	unbir mar sinp ///
	np10k rel10k  ///
	cvdeaths cvdmort_rte ///
	pavt census ///
	black hisp age loginc bach inv_sin inv_unb
	
foreach var of global socap {
	egen z`var' = std(`var')
}

foreach var of global socap {
	gen p`var' = (`var')*100
}

gen incol = zvcr*-1

global zsocap zunbir zmar zsingpar ///
	znp10k zrel10k informciv ///
	zpavt zcensus2010 instconf ///
	zvcr zblk_pct zhisp_pct zage65_pct zpbachc
	


**subindex macros**
global coll zvcr
global famu	zunbir zmar zsingpar
global civs znp10k zrel10k
global altciv  znp10k zrel10k informciv
global inst	zpavt zcensus2010
global altinst zpavt zcensus2010 instconf





//summarize sc
//return list
//global sch = round(r(mean) + r(sd), 0.01)
//global scm = round(r(mean), 0.01)
//global scl = round(r(mean) - r(sd), 0.01)



gen hidev = hid18 // high damage ever

tab date hid18


replace hid18 = 1 if date >= 681 & date <=699  & hidev == 1
tab date hid18





gen log_cvd = ln(cvdmort_rte)
swilk log_cvd


gen fm = zinv_sin + zinv_unb + zmar
gen ics = zrel10k + znp10k
gen aih = rel10k + znp10k
gen ih = zpavt + zcensus
gen aic = zpavt + zcensus
gen ce = zvcr*(-1)


local scs fm ics ic ce aih aic
foreach var of local scs {
	egen z`var' = std(`var')
}

gen sc = zfm + zics + zic + zce
egen zsc = std(sc)




gen poptot = pop

gen hundo = cvdmort_rte*10


keep cvdmort_rte pblack phisp page pbach loginc ///
	sc fm mar sinp unbir ics rel10k np10k ih census pvote12 pvote16 ///
	ce vcr hid18 date bach fips month
	



egen misss = rmiss(*)
drop if miss > 0
global controls pblack phisp bach page loginc


gen cdate = (date - 648)

gen dev = 0
replace dev= 1 if hid18 > 0

xtset fips date

gen jan = 0
replace jan = 1 if month == 1
gen feb = 0
replace feb = 1 if month == 2
gen mar = 0
replace mar = 1 if month == 3
gen apr = 0
replace apr = 1 if month == 4
gen may = 0
replace may = 1 if month == 5
gen jun = 0
replace jun = 1 if month == 6
gen jul = 0
replace jul = 1 if month == 7
gen aug = 0
replace aug = 1 if month == 8
gen sep = 0
replace sep = 1 if month == 9
gen oct = 0
replace oct = 1 if month == 10
gen nov = 0
replace nov = 1 if month == 11
gen dec = 0
replace dec = 1 if month == 12

global months jan feb mar apr may jun jul aug sep oct nov dec

gen ldmg = 0 
replace ldmg = 1 if hid18 == 1
replace ldmg = . if hid18 == 2

gen hidmg = 0 
replace hidmg = 1 if hid18 == 2
replace hidmg = . if hid18 == 1

stop

twoway (tsline meancvdm if date <= 681 & hidev == 0 , lcolor(navy)) ///
	(tsline meancvdm if date >= 681 & hidev == 0, lcolor(navy)) ///
	(tsline meancvdm if date <= 681 & hidev == 1, lcolor(maroon)) ///
	(tsline meancvdm if date >= 681 & hidev == 1, lcolor(maroon)) ///
	(tsline meancvdm if date <= 681 & hidev == 2, lcolor(dkgreen)) ///
	(tsline meancvdm if date >= 681 & hidev == 2, lcolor(dkgreen)) ///
	,xlabel(,angle(45) format(%tm)) ///
	xline(681, lcolor(black) lp(dot)) 
	
	

xtpoisson cvdmort_rte c.date##i.hidev $months, irr vce(robust) fe exposure(poptot)
xtpoisson cvdmort_rte c.date##i.hidev $controls $months, irr vce(robust) fe exposure(poptot)
xtpoisson cvdmort_rte c.date##i.hidev $controls $months, irr vce(robust) fe exposure(poptot)
margins, atmeans at(date = (636(3)707) hidev = (0 1))

marginsplot, recast(line) recastci(rarea) ciopts(color(%20)) xline(681)

xtpoisson cvdmort_rte c.date##c.sc ///
	$controls $months if hidev == 1, vce(robust) fe
xtpoisson cvdmort_rte c.date##c.fm ih ic ce ///
	$controls $months if hidev == 1, vce(robust) fe irr
xtpoisson cvdmort_rte fm  c.date##c.ih ic ce ///
	$controls $months if hidev == 1, vce(robust) fe irr
xtpoisson cvdmort_rte fm  ih c.date##c.ic ce ///
	$controls $months if hidev == 1, vce(robust) fe irr
xtpoisson cvdmort_rte fm  ih ic c.date##c.ce ///
	$controls $months if hidev == 1, vce(robust) fe irr

xtpoisson cvdmort_rte i.hidev##c.cdate $months $controls, exposure(poptot) irr vce(robust) fe
margins, at(cdate = (0(3)60) hidev = (0 1))
marginsplot, xtitle("Week of Year") xlab(,angle(45)) ///
	ciopts(color(%20)) recast(line)
	
xtpoisson cvdmort_rte c.date##i.ldmg cage phisp pblack ///
	pbach loginc $months, irr vce(robust) fe

xtpoisson cvdmort_rte c.date hid18 fm ih ic ce cage phisp pblack ///
	pbach loginc $months, irr vce(robust) fe
	

xtpoisson cvdmort_rte c.date##i.hid18 fm ih ic ce cage phisp pblack ///
	pbach loginc %months, irr vce(robust) fe
	
margins, at(date = (600 681 682 695) hid18 = (0 1 2))
marginsplot, xline(681) xmlabel(681 "Impact", angle(45) labs(vsmall)) ///
	ytitle("IRR Change") xtitle("Week of Year") xlab(,angle(45)) ///
	ciopts(color(%10)) recastci(rarea)
	
xtpoisson cvdmort_rte date##i.hid18
	

xpoisson meancvdm i.hid18##c.date if date < 681
margins, at(date = (672 681) hid18 = (0 1 2))
marginsplot



**Regression adjustment**
teffects nnmatch ///
	(cvdmort_rte pblack phisp page pbach loginc) ///
	(hidmg), dmv vce(robust)
	
teffects nnmatch ///
	(cvdmort_rte page pbach loginc) ///
	(hidmg), dmv vce(robust)  biasadj(loginc) ///
	ematch(year) osample(v)
lincom [cvdmort_rte]_b[1.hidmg], eform
margins ,at(date = (600 681 682 695))
marginsplot
tab v
drop v
	
teffects psmatch ///
	(cvdmort_rte) ///
	(hidmg pblack phisp page pbach loginc), vce(robust)
	
teffects ra (cvdmort_rte $months, poisson) (hid18), pomeans
teffects ra (cvdmort_rte $months ,poisson) (hid18), atet vce(robust) irr
asdoc replay, replace nest tzok dec(3) setstars(*@.05, **@.01, ***@.001) se(below) eform
teffects ra (cvdmort_rte ///
	fm ics ih ce $months, poisson) (hid18), atet aeq
asdoc replay, nest tzok dec(3) setstars(*@.05, **@.01, ***@.001) se(below) eform
teffects ra (cvdmort_rte pblack phisp page pbach loginc ///
	fm ics ih ce $months, poisson) (hid18), atet aeq
asdoc replay, nest tzok dec(3) setstars(*@.05, **@.01, ***@.001) se(below) eform
	
** The ATET of CVD mortality is .15% higher than the baseline CVD mortality rate
** of 2.33 CVD deaths/10,000 in a given county. Mean lowdmg pop = 714,369.89.
** .18% increase in mortality rate translate of an increase from 2.33 to 2.48
** or about 11 extra CVD deaths in the mean county over the course
** of the study
** 714,369.89/10,000 people. An increase of 0.15 CVD deahts/10,000
** The maean county in the sample had 187387 people. 
**.15* (714,369.89 (2018 mid year pop hidmg average)/10,000) = about 11
	
teffects ra (cvdmort_rte pblack phisp page pbach loginc ///
	fm ics ih ce $months, poisson) (hid18), atet aeq coeflegend


estat summarize
	
nlcom _b[ATE:r1vs0.hid18] / _b[POmean:0.hid18]
nlcom _b[ATE:r2vs0.hid18] / _b[POmean:0.hid18]

//too few groups, large point estimates

xtpoisson cvdmort_rte c.date##c.sc ///
	 $months if hid18 == 1, vce(robust) pa irr
asdoc replay, replace nest tzok dec(3) setstars(*@.05, **@.01, ***@.001) se(below) eform
xtpoisson cvdmort_rte c.date##c.sc ///
	 $months $controls if hid18 == 1, vce(robust) pa irr
asdoc replay, nest tzok dec(3) setstars(*@.05, **@.01, ***@.001) se(below) eform
xtpoisson cvdmort_rte c.date##c.fm ics ih ce ///
	 $months $controls if hid18 == 1, vce(robust) pa irr
asdoc replay, nest tzok dec(3) setstars(*@.05, **@.01, ***@.001) se(below) eform	 
xtpoisson cvdmort_rte fm  c.date##c.ics ih ce ///
	$controls $months if hid18== 1, vce(robust) pa irr
asdoc replay, nest tzok dec(3) setstars(*@.05, **@.01, ***@.001) se(below) eform	 
xtpoisson cvdmort_rte fm  ics c.date##c.ih ce ///
	$controls $months if hid18 == 1, vce(robust) pa irr
asdoc replay, nest tzok dec(3) setstars(*@.05, **@.01, ***@.001) se(below) eform
xtpoisson cvdmort_rte fm  ics ih c.date##c.ce ///
	$controls $months if hid18 == 1, vce(robust) pa irr
asdoc replay, nest tzok dec(3) setstars(*@.05, **@.01, ***@.001) se(below) eform	 

	
xtpoisson cvdmort_rte c.date##c.sc ///
	 $months if hid18 == 2, vce(robust) pa irr
asdoc replay, replace nest tzok dec(2) setstars(*@.05, **@.01, ***@.001) se(below) eform
xtpoisson cvdmort_rte c.date##c.sc ///
	 $months $controls if hid18 == 2, vce(robust) pa irr
asdoc replay, nest tzok dec(2) setstars(*@.05, **@.01, ***@.001) se(below)	 eform
xtpoisson cvdmort_rte c.date##c.fm ics ih ce ///
	 $months $controls if hid18 == 2, vce(robust) pa irr
asdoc replay, nest tzok dec(2) setstars(*@.05, **@.01, ***@.001) se(below)	 eform
xtpoisson cvdmort_rte fm  c.date##c.ics ih ce ///
	$controls $months if hid18== 2, vce(robust) pa irr
asdoc replay, nest tzok dec(2) setstars(*@.05, **@.01, ***@.001) se(below)	eform
xtpoisson cvdmort_rte fm  ics c.date##c.ih ce ///
	$controls $months if hid18 == 2, vce(robust) pa irr
asdoc replay, nest tzok dec(2) setstars(*@.05, **@.01, ***@.001) se(below)	eform
xtpoisson cvdmort_rte fm  ics ih c.date##c.ce ///
	$controls $months if hid18 == 2, vce(robust) pa irr
asdoc replay, nest tzok dec(2) setstars(*@.05, **@.01, ***@.001) se(below)	eform


	
sum fm ics ic ce
	
**Prehurricane Trends
preserve 
collapse (mean) cvdmort_rte, by(hid18 date)
reshape wide cvdmort_rte, i(date) j(hid18)
gen yr = yofd(dofm(date))
egen yravg0 = mean(cvdmort_rte0), by(yr)
egen yravg1 = mean(cvdmort_rte1), by(yr)
egen yravg2 = mean(cvdmort_rte2), by(yr)
graph twoway line yravg0 yravg1 yravg2 yr, ///
		title("Yearly Pre-Matthew CVD Mortality Rate Trends by Damage", size(large)) ///
		xmlabel(2016.83 "Impact", angle(45) labs(vsmall)) ///
		xline(2016.83, lcol(black) lpat(dot)) ///
		xlabel(, angle(45) labs(medium) format(%ty)) ///
		ytitle("CVD Mortality Rate") xtitle("Date (Year)") ///
		legend(order( 1 "No Damage" 2 "Low Damage" 3 "High Damage") col(3))
restore



gen issc = 0
replace issc = -1.43 if fips >= 12000 & fips <= 12999
replace issc = -0.84 if fips >= 13000 & fips <= 13999
replace issc = -0.79 if fips >= 37000 & fips <= 37999
replace issc = -0.60 if fips >= 45000 & fips <= 45999
replace issc =  0.34 if fips >= 51000 & fips <= 51999

gen icc = 0
replace icc = -0.71 if fips >= 12000 & fips <= 12999
replace icc = -0.29 if fips >= 13000 & fips <= 13999
replace icc =  0.05 if fips >= 37000 & fips <= 37999
replace icc =  0.33 if fips >= 45000 & fips <= 45999
replace icc =  0.43 if fips >= 51000 & fips <= 51999

hist issc, freq title("Informal Civil Society Coefficient Values")
hist icc, freq title("Institutional Confidience Coefficient Values")


gen sinp100 = sinp*100
asdoc sum cvdmort_rte hid18 ///
	sc fm sinp100 unbir marr ///
	ih np10k rel10k ///
	ic census pvote12 pvote16 /// 
	ce vcr $controls, ///
	tzok dec(2) replace ///
	stat(mean sd p50 p25 p75 iqr N)
	
 tabstat cvdmort_rte hid18 ///
	sc fm sinp100 unbir marr ///
	ih np10k rel10k ///
	ics census pvote12 pvote16 /// 
	ce vcr $controls, ///
	stat(mean sd p50 p25 p75 iqr N)
	

	
	
asdoc ttest cvdmort_rte, by(hidmg) replace tzok dec(2)
	asdoc ttest sc , by(hidmg) rowappend tzok dec(2)
	asdoc ttest fm , by(hidmg) rowappend tzok dec(2)
	asdoc ttest sinp100 , by(hidmg) rowappend tzok dec(2)
	asdoc ttest unbir , by(hidmg) rowappend tzok dec(2)
	asdoc ttest mar , by(hidmg) rowappend  tzok dec(2)
	asdoc ttest ih , by(hidmg) rowappend tzok dec(2)
	asdoc ttest np10k , by(hidmg) rowappend tzok dec(2)
	asdoc ttest rel10k , by(hidmg) rowappend tzok dec(2)
	asdoc ttest ic , by(hidmg) rowappend tzok dec(2)
	asdoc ttest census , by(hidmg) rowappend tzok dec(2)
	asdoc ttest pvote12 , by(hidmg) rowappend tzok dec(2)
	asdoc ttest pvote16 , by(hidmg) rowappend tzok dec(2)
	asdoc ttest ce , by(hidmg) rowappend tzok dec(2)
	asdoc ttest vcr , by(hidmg) rowappend tzok dec(2)
	asdoc ttest page , by(hidmg) rowappend tzok dec(2)
	asdoc ttest pblack , by(hidmg) rowappend tzok dec(2)
	asdoc ttest phisp , by(hidmg) rowappend tzok dec(2)
	asdoc ttest bach , by(hidmg) rowappend tzok dec(2)
	asdoc ttest loginc , by(hidmg) rowappend tzok dec(2)
	
	
asdoc ttest cvdmort_rte, by(ldmg) replace tzok dec(2)
	asdoc ttest sc , by(ldmg) rowappend tzok dec(2)
	asdoc ttest fm , by(ldmg) rowappend tzok dec(2)
	asdoc ttest sinp100 , by(ldmg) rowappend tzok dec(2)
	asdoc ttest unbir , by(ldmg) rowappend tzok dec(2)
	asdoc ttest mar , by(ldmg) rowappend  tzok dec(2)
	asdoc ttest ics , by(ldmg) rowappend tzok dec(2)
	asdoc ttest np10k , by(ldmg) rowappend tzok dec(2)
	asdoc ttest rel10k , by(ldmg) rowappend tzok dec(2)
	asdoc ttest ih , by(ldmg) rowappend tzok dec(2)
	asdoc ttest census , by(ldmg) rowappend tzok dec(2)
	asdoc ttest pvote12 , by(ldmg) rowappend tzok dec(2)
	asdoc ttest pvote16 , by(ldmg) rowappend tzok dec(2)
	asdoc ttest ce , by(ldmg) rowappend tzok dec(2)
	asdoc ttest vcr , by(ldmg) rowappend tzok dec(2)
	asdoc ttest page , by(ldmg) rowappend tzok dec(2)
	asdoc ttest pblack , by(ldmg) rowappend tzok dec(2)
	asdoc ttest phisp , by(ldmg) rowappend tzok dec(2)
	asdoc ttest bach , by(ldmg) rowappend tzok dec(2)
	asdoc ttest loginc , by(ldmg) rowappend tzok dec(2)
	
asdoc spearman cvdmort_rte ///
	sc fm sinp unbir mar ///
	ics census np10k rel10k  ///
	ih pvote12 pvote16 /// 
	ce, star(.05) tzok dec(2) replace