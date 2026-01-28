	* Author: Fahad Mirza
	* Date Created: Jan 9, 2026
	* Last Modified: Jan 28, 2026
	
	* Notes: The code makes use of "graphfunctions" by Asjad Naqvi
		* Install the package once:
			* ssc install graphfunctions, replace
	
	* Generating a proportional area chart (half circle)
	* Inspiration: http://www.thevisualagency.com/ar14/
	* Idea: https://datavizproject.com/data-type/proportional-area-chart-half-circle/
	
	
	clear
	
********************************************************************************	
	* Generate sample data on 12 categories
	set obs 12
	generate data2013 = runiform(0.25, 1)
	generate data2014 = runiform(0.25, 1)	
	
	generate category = "" 
	capture replace  category = "Category A" in 1
	capture replace  category = "Category B" in 2
	capture replace  category = "Category C" in 3
	capture replace  category = "Category D" in 4
	capture replace  category = "Category E" in 5
	capture replace  category = "Category F" in 6
	capture replace  category = "Category G" in 7
	capture replace  category = "Category H" in 8
	capture replace  category = "Category I" in 9
	capture replace  category = "Category J" in 10
	capture replace  category = "Category K" in 11
	capture replace  category = "Category L" in 12	
	
	generate title = "Sample Text" in 1
	
	
	**************************************************
	**************************************************
	**************************************************
	
	
	* All settings for the plot
		
	* Choose on how many spokes you required for categories
	* The dummy data will be generated based on the number of sides needed
	* This is the main local for the plot
	local nsides 	7
	
		
	* This setting brings category 1 or A to the top.
	* Change local to 0 if you do not want that.
	local topside 	1
	
	if `topside' == 1 {
		
		local rotate0 	`=90 - (360/`nsides')'
		
	}
	
	else {
	
		local rotate0 	0
		
	}
	
	* Text for center of figure
		* Using labsplit from graphfunctions
		* labsplit title, wrap(7) strict
	* encode title , gen(_title)
	* 
	* local modifytitle 	1
	* 
	* if `modifytitle' == 1 {
	* 	
	* 	label define _title 1 `" Sample`=char(13)'`=char(10)'   Text "', replace
	* 	
	* }
	
	local titletext "`=title[1]'"
	
	

	
	* Position of the circles on the spoke (This is a multiplier value)
	local circpos 0.85
	
	* Size of spokes on which the circles will be generated
	local spokeradius 	8
	
	* Width of the spokes
	local spokewidth 0.2
	
	* Size of the solid shape at the center of the visual (Radius size)
	local shaperadius 	3
	
	* Line width for the circles being created on the spoke (Multiplier)
	local circlwidth 	1.25
	
	
	* Label Sizes and Category Label Rotation
	
		* Size of the center text
		local titlesize 1.5	
		
		* Text size for the label being displayed on the maxima of each circle
		local maxlabsize 	0.65
		
		* Category label size
		local catlabsize 1
		
		* Setting to rotate the Category label
		* If the value is 0 then the category label will follow the angle of the spoke
		* If the value is 1 then the category label will keep the category text horizontal
		local catlabelrot 	1		
	
	
	* Offsets
	
		* Category Label offset for all labels being shown on the outside of the spoke
		local offset 		1.15
		
		* How far above the circle would you like to display the maximum value (This is an addition)
		local maxlaboffset 	0.4	
		
		* For Max value labels on 90 and 270 degrees, how far away should they be positioned from the circle
		* This is a multiplier
		local maxlabgapvert 0.2	
	
	
	* Colors
	
		* Circle 1 color
		local oddcirccol "224 106 75"
		
		* Circle 2 color
		local evencirccol "98 180 197"
		
		* Spoke line color
		local spokelcolor "200 200 200"
		
		* Color of the center shape
		local shapecolor "220 220 220"
		
		* Color for center text
		local titlecolor "100 100 100"
		
		* Category color on the spokes
		local catcolor 	"175 175 175"
		
		
	* Opacity of circle and center shape
	
		* Opacity of the center shape color
		local shapeopacity 100	
		
		* Opacity of circles created on the spoke
		local circlopacity 	100		
	
	
	**************************************************
	**************************************************
	**************************************************
	
	
	* Collect all original variable list
	ds *
	local keepvars `r(varlist)'	
	
	
	* Generating the grid lines extent (size of spokeradius) and the heptagon extent (size of shaperadius)
	set obs `= `=_N' + (`nsides' * 2)'
	shapes circle, radius(`spokeradius') n(`nsides') rotate(`rotate0') replace
	shapes circle, radius(`shaperadius') n(`nsides') rotate(`rotate0') append
	
	* Generating 80% of the grid length
	generate double _x80pct = `circpos' * _x
	generate double _y80pct = `circpos' * _y
	
	* Generating extent of the position where category label will be placed (offset)
	generate double _x120pct = `offset' * _x
	generate double _y120pct = `offset' * _y	

	* Generating starting point for the grid lines
	generate x0 = 0 if _id == 1 & _order <= `nsides'
	generate y0 = 0 if _id == 1 & _order <= `nsides'
	
	
	***********
	
	
	* Looping over number of sides
	forvalues i = 1/`nsides' {
		
		* Generating spokes based on the number of sides defined in the settings above
		local gridlines "`gridlines' (scatteri `=y0[`i']' `=x0[`i']' `=_y[`i']' `=_x[`i']' , recast(line) ms(i) lcolor("`spokelcolor'") lwidth(`spokewidth')) "
		
		* Generating circles to add to the grid lines (using a loop)
		shapes pie, x0(`=_x80pct[`i']') y0(`=_y80pct[`i']') start(0) end(180) rotate(`=(360/`nsides' + `rotate0') + (360/`nsides' * (`i' - 1))') rad(`=data2013[`i']') dropbase append
		shapes pie, x0(`=_x80pct[`i']') y0(`=_y80pct[`i']') start(0) end(180) rotate(`=(360/`nsides' + `rotate0') + (360/`nsides' * (`i' - 1))') rad(`=data2014[`i']') dropbase flip append
		
		
		* Creating labels for each category (Takes into account multiple settings)
		
		* Sequence when Category label rotation is enabled and categories are starting from the top
		if inlist(`catlabelrot', 1) & `topside' == 1 {
		
			if `=(360/`nsides' - 90 + `rotate0') + (360/`nsides' * (`i' - 1))' == 180 {
				
				local scatterlabels "`scatterlabels' (scatteri `=y0[`i']' `=x0[`i']' `=_y120pct[`i']' `=_x120pct[`i']' "`=category[`i']'", ms(i) mlabcolor("`catcolor'") mlabangle(`=(360/`nsides' - 90 + `rotate0') + (360/`nsides' * (`i' - 1)) - 180') mlabpos(0) mlabsize(*`catlabsize')) "
				
			}
			
			else if `=(360/`nsides' - 90 + `rotate0') + (360/`nsides' * (`i' - 1))' == 0 {
				
				local scatterlabels "`scatterlabels' (scatteri `=y0[`i']' `=x0[`i']' `=_y120pct[`i']' `=_x120pct[`i']' "`=category[`i']'", ms(i) mlabcolor("`catcolor'") mlabangle(`=(360/`nsides' - 90 + `rotate0') + (360/`nsides' * (`i' - 1))') mlabpos(0) mlabsize(*`catlabsize')) "
				
			}		
			
			else if `=(360/`nsides' - 90 + `rotate0') + (360/`nsides' * (`i' - 1))' > 0 & `=(360/`nsides' - 90 + `rotate0') + (360/`nsides' * (`i' - 1))' < 180 {
				
				* Subtracting the angle of each spoke from the label angle
				local catangle = `=(360/`nsides' - 90 + `rotate0') + (360/`nsides' * (`i' - 1)) - (360/`nsides' * (`i' - 1))' 
				
				local scatterlabels "`scatterlabels' (scatteri `=y0[`i']' `=x0[`i']' `=_y120pct[`i']' `=_x120pct[`i']' "`=category[`i']'", ms(i) mlabcolor("`catcolor'") mlabangle(`catangle') mlabpos(9) mlabgap(*-1.5) mlabsize(*`catlabsize')) "
				
			}
			
			else {
				
				* Subtracting the angle of each spoke from the label angle
				local catangle = `=(360/`nsides' - 90 + `rotate0') + (360/`nsides' * (`i' - 1)) - (360/`nsides' * (`i' - 1))' 
													
				local scatterlabels "`scatterlabels' (scatteri `=y0[`i']' `=x0[`i']' `=_y120pct[`i']' `=_x120pct[`i']' "`=category[`i']'", ms(i) mlabcolor("`catcolor'") mlabangle(`catangle') mlabpos(3) mlabgap(*-1.5) mlabsize(*`catlabsize')) "
				
			}		
		
		}
		
		
		* Sequence when category label does not start from the top but rotation is enabled
		else if inlist(`catlabelrot', 1) & `topside' == 0 {
		
			if `=(360/`nsides' - 90 + `rotate0') + (360/`nsides' * (`i' - 1))' == 180 {
				
				local scatterlabels "`scatterlabels' (scatteri `=y0[`i']' `=x0[`i']' `=_y120pct[`i']' `=_x120pct[`i']' "`=category[`i']'", ms(i) mlabcolor("`catcolor'") mlabangle(`=(360/`nsides' - 90 + `rotate0') + (360/`nsides' * (`i' - 1)) - 180') mlabpos(0) mlabsize(*`catlabsize')) "
				
			}
			
			else if `=(360/`nsides' - 90 + `rotate0') + (360/`nsides' * (`i' - 1))' == 0 {
				
				local scatterlabels "`scatterlabels' (scatteri `=y0[`i']' `=x0[`i']' `=_y120pct[`i']' `=_x120pct[`i']' "`=category[`i']'", ms(i) mlabcolor("`catcolor'") mlabangle(`=(360/`nsides' - 90 + `rotate0') + (360/`nsides' * (`i' - 1))') mlabpos(0) mlabsize(*`catlabsize')) "
				
			}		
			
			else if `=(360/`nsides' - 90 + `rotate0') + (360/`nsides' * (`i' - 1))' > 0 & `=(360/`nsides' - 90 + `rotate0') + (360/`nsides' * (`i' - 1))' < 180 {
				
				* Subtracting the angle of each spoke from the label angle
				local catangle = `=(360/`nsides' - 90 + `rotate0') + (90 - (360/`nsides'))' 
				
				local scatterlabels "`scatterlabels' (scatteri `=y0[`i']' `=x0[`i']' `=_y120pct[`i']' `=_x120pct[`i']' "`=category[`i']'", ms(i) mlabcolor("`catcolor'") mlabangle(`catangle') mlabpos(9) mlabgap(*-1.5) mlabsize(*`catlabsize')) "
				
			}
			
			else {
				
				* Subtracting the angle of each spoke from the label angle
				local catangle = `=(360/`nsides' - 90 + `rotate0') + (90 - (360/`nsides'))' 
													
				local scatterlabels "`scatterlabels' (scatteri `=y0[`i']' `=x0[`i']' `=_y120pct[`i']' `=_x120pct[`i']' "`=category[`i']'", ms(i) mlabcolor("`catcolor'") mlabangle(`catangle') mlabpos(3) mlabgap(*-1.5) mlabsize(*`catlabsize')) "
				
			}		
		
		}
		
		
		else if `=(360/`nsides' - 90 + `rotate0') + (360/`nsides' * (`i' - 1))' == 180 {
			
			* Case where there is a category at 180 degrees regardless of any rotation
			local catangle = `=(360/`nsides' - 90 + `rotate0') + (360/`nsides' * (`i' - 1)) - 180'
			
			local scatterlabels "`scatterlabels' (scatteri `=y0[`i']' `=x0[`i']' `=_y120pct[`i']' `=_x120pct[`i']' "`=category[`i']'", ms(i) mlabcolor("`catcolor'") mlabangle(`catangle') mlabpos(0) mlabsize(*`catlabsize')) "
			
			
		}
		
		else {
			
			* All other cases
			local scatterlabels "`scatterlabels' (scatteri `=y0[`i']' `=x0[`i']' `=_y120pct[`i']' `=_x120pct[`i']' "`=category[`i']'", ms(i) mlabcolor("`catcolor'") mlabangle(`=(360/`nsides' - 90 + `rotate0') + (360/`nsides' * (`i' - 1))') mlabpos(0) mlabsize(*`catlabsize')) "
			
			
		}
		
		* display `=(360/`nsides' - 90 + `rotate0') + (360/`nsides' * (`i' - 1))'
		
	}
	
		
	* For circle highest values label 
	forvalues i = 1/`nsides' {
		
		if `=(360/`nsides' + `rotate0') + (360/`nsides' * (`i' - 1))' == 90 {
			
			shapes pie, x0(`=_x80pct[`i']') y0(`=_y80pct[`i']') start(0) end(180) rotate(`=(360/`nsides' + `rotate0') + (360/`nsides' * (`i' - 1))') rad(`=data2013[`i'] + `maxlaboffset' + (1*`maxlabgapvert')') dropbase genx(circfx) geny(circfy) append
			shapes pie, x0(`=_x80pct[`i']') y0(`=_y80pct[`i']') start(0) end(180) rotate(`=(360/`nsides' + `rotate0') + (360/`nsides' * (`i' - 1))') rad(`=data2014[`i'] + `maxlaboffset' + (1*`maxlabgapvert')') dropbase flip genx(circfx) geny(circfy) append	
			
		}
		
		else if `=(360/`nsides' + `rotate0') + (360/`nsides' * (`i' - 1))' == 270 {
			
			shapes pie, x0(`=_x80pct[`i']') y0(`=_y80pct[`i']') start(0) end(180) rotate(`=(360/`nsides' + `rotate0') + (360/`nsides' * (`i' - 1))') rad(`=data2013[`i'] + `maxlaboffset' + (1*`maxlabgapvert')') dropbase genx(circfx) geny(circfy) append
			shapes pie, x0(`=_x80pct[`i']') y0(`=_y80pct[`i']') start(0) end(180) rotate(`=(360/`nsides' + `rotate0') + (360/`nsides' * (`i' - 1))') rad(`=data2014[`i'] + `maxlaboffset' + (1*`maxlabgapvert')') dropbase flip genx(circfx) geny(circfy) append	
			
		}		
		
		else {
			shapes pie, x0(`=_x80pct[`i']') y0(`=_y80pct[`i']') start(0) end(180) rotate(`=(360/`nsides' + `rotate0') + (360/`nsides' * (`i' - 1))') rad(`=data2013[`i'] + `maxlaboffset'') dropbase genx(circfx) geny(circfy) append
			shapes pie, x0(`=_x80pct[`i']') y0(`=_y80pct[`i']') start(0) end(180) rotate(`=(360/`nsides' + `rotate0') + (360/`nsides' * (`i' - 1))') rad(`=data2014[`i'] + `maxlaboffset'') dropbase flip genx(circfx) geny(circfy) append
		}
				
		
	}
		
	* Generating lines to generate the circles (Starts from ID 3 as ID 1 and 2 create the spoke and center shape)
	forvalues j = 3(2)`=(`nsides'*2) + 1' {
		
		local oddcirc "`oddcirc' (line _y _x if _id == `j', lwidth(*`circlwidth') lcolor("`oddcirccol'%`circlopacity'") lalign(inside)) "
		local evencirc "`evencirc' (line _y _x if _id == `=`j' + 1', lwidth(*`circlwidth') lcolor("`evencirccol'%`circlopacity'") lalign(inside)) "
		
	}
	
	
	
	* Finding the center of _x (p50/median) and _y (p50/median) to mark highest value along with its label point
	sort _id , stable
	by _id: egen double median_order = median(_order) if _id > 2 & !missing(_y)
	replace median_order = 16 if !missing(circfy)
	
	generate double _xp50 = _x if _order == median_order
	generate double _xpv50 = circfx if (_order == median_order) & !missing(circfx)
	
	generate double _yp50 = _y if _order == median_order
	generate double _ypv50 = circfy if (_order == median_order) & !missing(circfy)	
	
	
	preserve
		
		keep _xpv50 _ypv50
		
		missings dropobs _xpv50 _ypv50, force
		
		egen even = seq(), from(0) to(1)
				
		tempfile maxpoints
		save "`maxpoints'"
		
	restore
	
	drop _xpv50 _ypv50
	merge 1:1 _n using "`maxpoints'", nogen
		
	
	* Label for highest value of odd and even circles generated above	
	local i = 1
	forvalues j = 1(2)`=(`nsides'*2) - 1' {
		
		*****
		if `=(360/`nsides' + `rotate0') + (360/`nsides' * (`i' - 1))' > 360 {
			
			local angle = `=(360/`nsides' + `rotate0') + (360/`nsides' * (`i' - 1))' - 360
			
		}
		
		else {
			
			local angle = `=(360/`nsides' + `rotate0') + (360/`nsides' * (`i' - 1))'
			
		}
		*****
		
		*****
		if `angle' == 90 {
			
			local angle = `=(360/`nsides' + `rotate0') + (360/`nsides' * (`i' - 1)) - 90'
			
			local oddcirclab "`oddcirclab' (scatteri `=_ypv50[`j']' `=_xpv50[`j']' "`: display %3.2f `=data2013[`i']''", ms(i) mlabpos(0) mlabangle(`angle') mlabcolor(gs3) mlabsize(*`maxlabsize')) "
			
			local evencirclab "`evencirclab' (scatteri `=_ypv50[`=`j' + 1']' `=_xpv50[`=`j' + 1']' "`: display %3.2f `=data2014[`i']''", ms(i) mlabpos(0) mlabangle(`angle') mlabcolor(gs3) mlabsize(*`maxlabsize')) "				
			
		}

		else if `angle' == 270 {
			
			local angle = `=(360/`nsides' + `rotate0') + (360/`nsides' * (`i' - 1)) + 90'
			
			local oddcirclab "`oddcirclab' (scatteri `=_ypv50[`j']' `=_xpv50[`j']' "`: display %3.2f `=data2013[`i']''", ms(i) mlabpos(0) mlabangle(`angle') mlabcolor(gs3) mlabsize(*`maxlabsize')) "
			
			local evencirclab "`evencirclab' (scatteri `=_ypv50[`=`j' + 1']' `=_xpv50[`=`j' + 1']' "`: display %3.2f `=data2014[`i']''", ms(i) mlabpos(0) mlabangle(`angle') mlabcolor(gs3) mlabsize(*`maxlabsize')) "				
			
		}

		else if `angle' > 90 & `angle' < 270 {
			
			local angle = `=(360/`nsides' + `rotate0') + (360/`nsides' * (`i' - 1)) - 180'
			
			local oddcirclab "`oddcirclab' (scatteri `=_ypv50[`j']' `=_xpv50[`j']' "`: display %3.2f `=data2013[`i']''", ms(i) mlabpos(0) mlabangle(`angle') mlabcolor(gs3) mlabsize(*`maxlabsize')) "
			
			local evencirclab "`evencirclab' (scatteri `=_ypv50[`=`j' + 1']' `=_xpv50[`=`j' + 1']' "`: display %3.2f `=data2014[`i']''", ms(i) mlabpos(0) mlabangle(`angle') mlabcolor(gs3) mlabsize(*`maxlabsize')) "
			
		}
				
		else {

			local oddcirclab "`oddcirclab' (scatteri `=_ypv50[`j']' `=_xpv50[`j']' "`: display %3.2f `=data2013[`i']''", ms(i) mlabpos(0) mlabangle(`angle') mlabcolor(gs3) mlabsize(*`maxlabsize')) "
			
			local evencirclab "`evencirclab' (scatteri `=_ypv50[`=`j' + 1']' `=_xpv50[`=`j' + 1']' "`: display %3.2f `=data2014[`i']''", ms(i) mlabpos(0) mlabangle(`angle') mlabcolor(gs3) mlabsize(*`maxlabsize')) "	
		
		}
		
		local ++i
	
	}		
	
	* display `"`oddcirclab'"'
	
	****************************************************************************
	
	
	* Putting it together and plotting
	twoway 	`gridlines' ///
			(area _y _x if _id == 2, nodropbase fcolor("`shapecolor'%`shapeopacity'") lwidth(0)) ///
			/// //Circles from here on
			`oddcirc' ///
			`evencirc' ///
			`scatterlabels' ///
			(scatter _yp50 _xp50 , mfcolor(red)) ///
			`oddcirclab' ///
			`evencirclab' ///
			/// (scatter _ypv50 _xpv50 , mfcolor(red) mlcolor(white) mlabpos(0) mlabangle(`=(360/`nsides' + `rotate0') + (360/`nsides' * (`i' - 1))')) ///
			/// (scatter y0 x0 in 1, ms(i) mlabpos(12) mlabsize(*`titlesize') mlabcolor("`titlecolor'") mlabel(_title) mlabgap(1)) ///
			(scatteri `=y0[1]' `=x0[1]' "`titletext'", ms(i) mlabpos(12) mlabsize(*`titlesize') mlabcolor("`titlecolor'")  mlabgap(-1.5)) ///
			, ///
			ytitle("") ///
			xtitle("") ///
			ylabel(none, nogrid) ///
			yscale(range(-`=`spokeradius' + 1' `=`spokeradius' + 1') noline) ///
			xlabel(none, nogrid) ///
			xscale(range(-`=`spokeradius' + 1' `=`spokeradius' + 1') noline) ///
			legend(order(`=`nsides' + 2' "2013" `=(`nsides' * 2) + 2' "2014") symysize(2) symxsize(2) ring(2) pos(4) size(2)) ///
			aspect(1)
			
	*exit
	* Drop intermediate variables
	keep `keepvars'
	quietly missings dropobs `keepvars', force
	
	
	*graph export "./Prop_Area_Chart_12_Categories.png", as(png) width(3840) replace

