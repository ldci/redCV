Red [
	Title:   "FFT tests "
	Author:  "Francois Jouen"
	File: 	 %fft2D.red
	Needs:	 'View
]
; required libs
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/timeseries/rcvFFT.red


; ***** TEST *******

dt: 0.1			
;re: make vector!  	[1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0]
re: make vector! 	[3.0 4.0 6.0 2.0 9.0 1.0 7.0 5.0 8.0]
im: make vector!  	[0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0]

n: length? re
t1: now/time/precise
are: rcvMat2Array re  3x3 			; vector to array
aim: rcvMat2Array im  3x3 			; vector to array
prin ["Source: " ] probe re
prin ["Array:  " ] probe are

rcvFFT2D are aim 1					; array
prin ["Forward:"] probe are
matRe: rcvArray2Mat are				; array to mat
matIm: rcvArray2Mat aim				; array to mat
matAm: rcvFFTAmplitude matRe matIm	; FFT amplitude
matPh: rcvFFTPhase matRe matIm false; FFT Phase
matFreq: rcvFFTFrequency n dt		; FFT frequency dt: inverse of sampling rate
prin ["Amplitude:"] probe matAm
prin ["Phase:    "] probe matPh
prin ["Frequency:"] probe matFreq
rcvFFT2D are aim -1					; array 
prin ["Inverse:" ] probe are
matRe: rcvArray2Mat are				; array to mat
matIm: rcvArray2Mat aim				; array to mat
prin ["Inverse:" ] probe matRe
print ["Done in " now/time/precise - t1]