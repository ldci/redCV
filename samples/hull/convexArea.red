Red [
	Title:   "Test images convolution Red VID "
	Author:  "Francois Jouen"
	File: 	 %convexArea.red
	Needs:	 'View
]


{Quick Hull implementation
Based on Alexander Hristov's Java code
http://www.ahristov.com/tutorial/geometry-games/convex-hull.html}



; all we need for computer vision with red
#include %../../libs/redcv.red ; for red functions


margins: 10x10		
isize: 256x256
nbpMax: 100
nbp: 3
radius: 2.5
cg: 0x0
img: rcvCreateImage isize

plot: copy []
points: copy []


random/seed now/time/precise

generatePoints: does [
	nbp: random nbpMax
	if nbp < 3 [nbp: 3]
	nbpf2/text: form nbp
	canvas/image/rgb: 0.0.0
	plot: copy [fill-pen green]
	canvas/image: draw img plot
	points: copy []
	i: 1
	while [i < (nbp + 1)] [
		p: random 128x128 
		p:  64x64 + p
		append points p
		append plot 'circle 
		append plot p
		append plot radius
		i: i + 1
	]
	append plot [fill-pen off line-width 1 pen red]
]


showHull: does [
	clear list/data 
	either cb2/data [chull: rcvQuickHull/ccw points] [chull: rcvQuickHull/cw points]
	n: length? chull
	append plot 'polygon
	sumX: 0
	sumY: 0
	; for centroid
	foreach p chull [append plot p sumX: sumX + p/x sumY: sumY + p/y]
	cg/x: sumX / n
	cg/y: sumY / n 
	
	if cb1/data [i: 1 foreach p chull [append plot reduce ['text p form (i)] i: i + 1]]
	i: 1
	foreach p chull [s: form i append append  s " : " to string! p
					append list/data s i: i + 1]
	
	if cb3/data [append plot reduce ['fill-pen red 'circle (cg) radius + 1]]
	if cb4/data [
		append plot [fill-pen off line-width 1 pen green line 0x128 256x128 
		pen off pen green line 128x0 128x256]
	]
	
	canvas/image: draw img plot
	if cb5/data [areaF/text: form rcvContourArea/signed chull]
]


view win: layout [
	title "Quick Convex Hull Area"
	origin margins space margins
	text "Max Number of points"
	nbpf: field 50 data nbpMax [if error? try [nbpMax: to integer! face/data] [nbp: nbp]]
	
	button 70 "Generate" [if error? try [nbpMax: to integer! nbpf/data] [nbpMax: nbpMax] 
						  generatePoints canvas/image: draw img plot showHull]
	nbpf2: field 50
	pad 200x0
	button 40 "Quit" 	[Quit]
	return
	cb1: check "Show Numbers"
	cb2: check 50 "CCW"
	cb3:  check "Centroid"
	cb4: check 50 "Axes"
	cb5:  check 60 "Area"
	areaF: field 100
	return 
	canvas: base 512x512 img
	list: text-list 100x512 data []
]
