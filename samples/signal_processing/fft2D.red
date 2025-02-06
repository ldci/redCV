Red [
	Title:   "FFT tests "
	Author:  "ldci"
	File: 	 %fft2D.red
	Needs:	 'View
]
; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/timeseries/rcvFFT.red


; ***** TEST *******

dt: 0.1			
re: 		matrix/create 3 64 3x3 [3.0 4.0 6.0 2.0 9.0 1.0 7.0 5.0 8.0]
im: 		matrix/create 3 64 3x3 [0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0]
matAm: 		matrix/init 3 64 3x3
matPh: 		matrix/init 3 64 3x3
matFreq: 	matrix/init 3 64 3x3

n: length? re/data
t1: now/time/precise
are: rcvMat2Array re  				; mat to array
aim: rcvMat2Array im   				; mat to array
prin ["Source: " ] probe re
prin ["Array:  " ] probe are

rcvFFT2D are aim 1 1					; FFT on array
prin ["Forward:"] probe are
vecRe: rcvArray2Vector are					; array to vector
vecIm: rcvArray2Vector aim					; array to vector
matAm/data: rcvFFTAmplitude vecRe vecIm		; FFT amplitude
matPh/data: rcvFFTPhase vecRe vecIm false	; FFT Phase
matFreq/data: rcvFFTFrequency n dt			; FFT frequency dt: inverse of sampling rate
prin ["Amplitude: "] probe matAm
prin ["Phase:     "] probe matPh
prin ["Frequency: "] probe matFreq
rcvFFT2D are aim -1	1				; array 
prin ["Inverse:" ] probe are
vecRe: rcvArray2Vector are				; array to mat
vecIm: rcvArray2Vector aim				; array to mat
re/data: vecRe
im/data: vecIm
prin ["Inverse: " ] probe re
print ["Done in " now/time/precise - t1]