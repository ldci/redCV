#!/usr/local/bin/red
Red [
	Title:   "Signal Processing"
	Author:  "Francois Jouen and Oldes"
	File: 	 %peaks.red
	Needs:	 View
	Note: https://stackoverflow.com/questions/22583391/peak-signal-detection-in-realtime-timeseries-data
]

lag: 4
threshold: 2.0
influence: 0.0

input: [1 1 1 -1 1 5 9 6 1 1 1 1 8 8 9 10 7 6 1 1 1 1 1 5 4 1 1 1 5 7 1 1 1 1 1 1 1 5 6 1
		1 1 1 5 3 5 1 1 3 1 1
]
sampleLenght: length? input
output: make vector! reduce ['integer! 8 sampleLenght]
imgSize: 512x128

img1: make image! imgSize
img2: make image! imgSize

mean: function [
	data [block! vector!]
	len  [integer!]
][
	sum: 0.0
	repeat i len [sum: sum + data/:i]
	sum / len
]

stddev: function [
	data [block! vector!]
	len  [integer!]
][
	_mean: mean data len
	sd: 0.0
	repeat i len [sd: sd + power (data/:i - _mean) 2]
	sqrt (sd / len)
]

thresholding: function [
	data      [block! vector!]
	output    [block! vector!]
	lag       [integer!]
	threshold [float!]
	influence [float!]
][
	sLenght: length? data	
	filteredY: copy data
	avgFilter: make vector! reduce ['float! 64 sLenght]
	stdFilter: make vector! reduce ['float! 64 sLenght]
	avgFilter/:lag: mean data lag
	stdFilter/:lag: stddev data lag
	i: lag
	while [i < sLenght][
		n:   i + 1          ;-- index of the next value
		y:   data/:n
		avg: avgFilter/:i
		std: stdFilter/:i

		v1: absolute (y - avg)
		v2: threshold * std

		either v1 > v2 [
			output/:n: pick [1 -1] y > avg
			filteredY/:n: (influence * y) + ((1 - influence) * filteredY/:i)
		][
			output/:n: 0
		]
		avgFilter/:n: mean   (at filteredY i - lag) lag
		stdFilter/:n: stddev (at filteredY i - lag) lag
		i: i + 1
	]
	filteredY
]

showInput: does [
	img1/rgb: 0.0.0
	plot1: reduce ['line-width 1 'pen green 'line]
	sampleLenght: length? input
	repeat i sampleLenght [append plot1 as-pair i * 10 64 - (input/:i * 5)]
	canvas1/image: draw img1 plot1
]

showOutPut: does [
	img2/rgb: 0.0.0
	plot2: reduce ['line-width 1 'pen red 'line]
	sampleLenght: length? output
	repeat i sampleLenght [append plot2 as-pair i * 10 64 - (output/:i * 25)]
	canvas2/image: draw img2 plot2
]

process: does [ 
	filtered: thresholding :input :output :lag :threshold :influence
	showInput showOutPut
]

view win: layout [
	title "Time Series [Peaks]"
	text 50 top bold "Lag"
	flag: field 40 [
		if error? try [lag: to-integer face/text][lag: 5] 
		flag/text: form lag
		process
	]
	text 70 top bold "Threshold" 
	fthresh: field 40 [
		if error? try [threshold: to-float face/text][threshold: 1.0]
		fthresh/text: form threshold
		process
	]
	text 70 top bold "Influence"
	finfluence: field 40 [
		if error? try [influence: to-float face/text][influence: 0.5]
		finfluence/text: form influence
		process
	]
	button "Process" [process]
	button "Quit" [Quit]
	return
	canvas1: base imgSize black img1
	return
	canvas2: base imgSize black img2
	do [
		flag/text: form lag fthresh/text: form threshold finfluence/text: form influence
		process
	]
]