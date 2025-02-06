Red [
	Title:   "FFT tests "
	Author:  "ldci"
	File: 	 %fft1D.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/timeseries/rcvFFT.red


; ***** TEST *******

re: make vector! [1.0 1.0 1.0 1.0 0.0 0.0 0.0 0.0]
im: make vector! [0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0]
len: length? re
probe re
probe im
print lf 
print "Fast Fourier Transform: forward"
t1: now/time/precise
rcvFFT re im 1 1
repeat i len [
	print [i ": " re/:i "," rejoin [im/:i"i"]]
]


print lf
print "Fast Fourier Transform: inverse"
; we should get original values 

rcvFFT re im -1 1

repeat i len [
	print [i ": " round re/:i "," rejoin [round im/:i "i"]]
]
print ["Done in " now/time/precise - t1]