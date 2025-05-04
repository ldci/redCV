Red [
	Description: 	"Discrete Fourier Transform"
	Author:  		"ldci"
	file:			%rosetta.red
	Date: 			"14-Sept-2019"
	Needs:			'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/timeseries/rcvFFT.red

process: does [
	result/text: copy ""
	re: make vector!  	[1.0 1.0 1.0 1.0 0.0 0.0 0.0 0.0]
	im: make vector!  	[0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0]
	either cb/data 	  	[rcvFFT re im -1 1 rcvFFT re im 1 1] 
						[rcvFFT re im -1 1]
	n: length? re
	i: 1
	repeat i n [
		s: rejoin[round/to re/:i 0.000001 "+" round/to im/:i 0.000001 "i" lf] 
		append result/text form s
	]
]


view win: layout [
	title "FFT1D Rosetta Code"
	cb: check "Inverse" [process]
	pad 150x0
	button "Quit" [quit]
	return
	base 295x16 white "1.0 1.0 1.0 1.0 0.0 0.0 0.0 0.0"
	return
	result: area 300x200
	do [process]
]