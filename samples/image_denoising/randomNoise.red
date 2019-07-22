#! /usr/local/bin/red
Red [
	Title:   "Gaussian Noise"
	Author:  "Francois Jouen"
	File: 	 %randomNoise.red
	Needs:	 View
]

#include %../../libs/redcv.red ; for redCV functions
isFile: false
size: 384x384
noise: 0.0
color: black
r: g: b: 0
;Nenad's to-color function'
to-color: function [r g b][
	color: 0.0.0
	if r [color/1: to integer! 256 * r]
	if g [color/2: to integer! 256 * g]
	if b [color/3: to integer! 256 * b]
	color
]


loadImage: does [
    isFile: false
	tmp: request-file
	if not none? tmp [
		img1: rcvloadImage tmp
		img2: rcvCreateImage img1/size
		rcvCopyImage img1 img2
		canvas1/image: img1
		canvas2/image: img2
		isFile: true
		noiseGenerator 
	]
]

noiseGenerator: does [
	random/seed now/time/precise
	if isFile [
		rcvCopyImage img1 img2 
		rcvImageNoise img2 noise color
		canvas2/image: img2
	]
]


view win: layout [
	title "Gaussian Noise"
	button 50 "Load" [loadImage]
	text 40 bold "Noise"
	sl: slider 50 [noise: to-float face/data f/text: form round/to noise 0.01 noiseGenerator]
	f: text bold 50 "0.0"
	text 40 bold "Red:" slR: slider 50 [r: to-integer slR/data * 255  
				fr/text: form r color/1: r] fr: text 30 bold right "0" 
	text 50 bold "Green:" slG: slider 50 [g: to-integer slG/data * 255  
					fg/text: form g color/2: g] fg: text 30 bold right "0"
	text 40 bold "Blue:" slB: slider 50 [b: to-integer slB/data * 255  
					fb/text: form b color/3: b] fb: text 30 bold right "0"
	bx1: base 45x24 react [face/color: to-color slR/data slG/data slB/data 
							color: face/color noiseGenerator]
	button 50 "Quit" [quit]
	return
	pad 12x0
	canvas1: base size black
	canvas2: base size black 			
	return
	pad 12x0
	text 778 center "© Red Foundation 2019"
]