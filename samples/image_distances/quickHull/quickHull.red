Red [
	Title:   "Test images convolution Red VID "
	Author:  "ldci"
	File: 	 %quickHull.red
	Needs:	 'View
]


{Quick Hull implementation
Based on Alexander Hristov's Java code
http://www.ahristov.com/tutorial/geometry-games/convex-hull.html}

; required libs
#include %../../../libs/core/rcvCore.red
;#include %../../../libs/tools/rcvTools.red
#include %../../../libs/math/rcvQuickHull.red

margins: 5x5
isize: 256x256
nbp: 15
radius: 3
img: rcvCreateImage isize

plot: copy [fill-pen green]
points: copy []


random/seed now/time/precise

generatePoints: does [
	canvas/image/rgb: 0.0.0
	plot: copy [fill-pen green]
	points: copy []
	i: 1
	while [i < (nbp + 1)] [
		p: random isize - 10
		append points p
		append plot 'circle 
		append plot p
		append plot radius
		i: i + 1
	]
	append plot [fill-pen off line-width 1 pen red]
]


showHull: does [
	either cb2/data [chull: rcvQuickHull/ccw points] [chull: rcvQuickHull/cw points]
	append plot 'polygon
	foreach p chull [append plot p]
	if cb1/data [i: 1 foreach p chull [append plot reduce ['text p form (i)] i: i + 1]]
	canvas/image: draw img plot
]


view win: layout [
	title "Quick Convex Hull"
	origin margins space margins
	text "Number of points"
	nbpf: field 50 [if error? try [nbp: to integer! face/data] [nbp: nbp]]
	cb1: check "Show Numbers"
	cb2: check "CCW"
	button 75 "Generate" [if error? try [nbp: to integer! nbpf/data] [nbp: nbp] 
						  generatePoints canvas/image: draw img plot showHull]
	button 50 "Quit" 	[Quit]
	return 
	canvas: base 512x512 img
	do [nbpf/text: form nbp]
]
