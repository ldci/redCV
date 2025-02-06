#! /usr/local/bin/red
Red [
	Title:   "Red Computer Vision: Voronoï Diagram"
	Author:  "ldci"
	File: 	 %voronoi.red
	Tabs:	 4
	Rights:  "Copyright (C) 2019 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
	Needs:	 View
]

;required libs
#include %../../../libs/tools/rcvTools.red
#include %../../../libs/core/rcvCore.red
#include %../../../libs/math/rcvDistance.red


size: 320x240

map: make image! reduce [size black]

nSeeds: 50			; number of sites
param: true			; show seeds
dparam: 1			; euclidian distance 
mparam: 3.0			; p value for Minkowski distance



randomSeeds: func [n] [collect [loop n [keep random size]]]
randomSeedsColor: func [n] [collect [loop n [keep random white]]]


process: does [
	random/seed now/time
	sxy: randomSeeds nSeeds 
	sc: randomSeedsColor nSeeds
	t1: now/time/precise
	rcvVoronoiDiagram sxy sc map param dparam mparam
	t2: now/time/precise
	t: rcvElapsed t1 t2
	f3/text: rejoin ["Rendered in: " t " ms"]
]


view win: layout [
	title "Voronoï Diagram 3"
	text  "Number of seeds" 
	f1: field 50 		 [if error? try [nSeeds: to-integer f1/text] [nSeeds: 30 f1/text: form nSeeds] process]
	text 60 "Distance"
	dp: drop-down 85 data ["Euclidian" "Manhattan" "Chessboard" "Minkowski" "Chebyshev" "Euclidian2"]
		select 1
		on-change [dparam: face/selected 
		either dparam = 4 [f2/visible?: true] [f2/visible?: false]
		process
	]
	f2: field 40 "3.0" 			[if error? try [mparam: to-float f2/text] [mparam: 3.0 f2/text: form mparam] process]
	cb: check "Show seeds" true [param: face/data]
	button 75 "Generate" 	 	[process]
	button 45 "Quit"   	 		[quit]
	return 
	img: base 640x480 map
	return
	text 150 "© Red Foundation 2019"
	f3: field 480
	do [f1/text: form nSeeds f2/visible?: false]
]