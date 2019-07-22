#! /usr/local/bin/red
Red [
	Title:   "Red Computer Vision: Distance Mapping"
	Author:  "Francois Jouen"
	File: 	 %mapdiagram.red
	Tabs:	 4
	Rights:  "Copyright (C) 2019 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
	Needs:	 View
]


; Based on Boleslav Březovský's sample
;it first creates some random points - peaks and 
;then it calculates distance from nearest peak from each point in image. 
;The shorter the distance is, the brighter the pixel is.
;This vesrsion includes Red/System code for a laster rendering

;'Some variables we need
#include %../../libs/redcv.red ; for redCV functions
size: 320x240		
map: make image! reduce [size black]

nSeeds: 30			; number of sites
param: true			; show seeds
dparam: 1			; euclidian distance 
mparam: 3.0			; p value for Minkowski distance
color: 	true
peaks: []
img: none
nSeeds: 50

;*********************** Red Functions ******************************

makeSeeds: func [n isize] [collect [loop n [keep random isize]]]
randomSeedsColor: func [n] [collect [loop n [keep random white]]]
randomSeedsMono: func [n] [collect [loop n [keep white]]]

process: does [
	random/seed now/time
	map/argb: black 
	peaks: makeSeeds nSeeds size
	either color [sc: randomSeedsColor nSeeds]
			     [sc: randomSeedsMono nSeeds]
	t1: now/time/precise
	rcvDistanceDiagram peaks sc map param dparam mparam 
	img/image: map
	t2: now/time/precise
	f/text: rejoin ["Rendered in: " round/to (third t2 - t1) 0.001 " sec"]
]

;******************** Main Program *********************************
view win: layout [
	title "Distance Map"
	text  "Number of seeds" 
	f1: field 50 	[if error? try [nSeeds: to-integer f1/text] [nSeeds: 30 
					f1/text: form nSeeds] process]
	text 60 "Distance"
	dp: drop-down 85 data ["Euclidian" "Manhattan" "Minkowski" "Chebyshev"]
		select 	1 
		on-change [
			dparam: face/selected
			either dparam = 3 [f2/visible?: true] [f2/visible?: false]
			process
		]
	f2: field 40 "3.0" [if error? try [mparam: to-float f2/text] [mparam: 3.0 
						f2/text: form mparam] process]
	check  60 "Seeds" param [param: face/data]
	check  60 "Color" color [color: face/data]
	button 65 "Create" 	 [process]
	button 50 "Quit"   	 [quit]
	return 
	pad 16x0 img: base 640x480 map
	return
	pad 16x0
	text 150 "© Red Foundation 2019"
	f: field 480
	do [f1/text: form nSeeds f2/visible?: false]
]


