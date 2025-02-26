#!/usr/local/bin/red-cli
Red [
	Author:  "ldci"
	File: %rgb2hsvCli.red
]

do %rgbhsv.red

print ["RGB Values:" 200 128 16]
print ["RGB2HSV:" rgbToHsv 200 128 16] 			;--37 0.92 0.784
print ["HSV2RGB:" hsvToRgb 37.0 0.92 0.784] 	;--200 128 16
print ["RGB Values:" 200 0 16]
print ["RGB2HSV:" rgbToHsv 200 0 16]			;--355 1.0 0.784
print ["HSV2RGB:" hsvToRgb 355.0 1.0 0.784]		;--200 0 16