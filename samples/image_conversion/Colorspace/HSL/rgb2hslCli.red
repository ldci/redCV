#!/usr/local/bin/red-cli
Red [
	Author:  "ldci"
	File: %rgb2hslCli.red
]

do %rgbhsl.red

print ["RGB Values:" 200 128 16]

print ["RGB2HSL:" b: rgbToHsl 200 128 16] 			
print ["HSL2RGB:" hslToRgb b/1 b/2 b/3]	
print ["RGB Values:" 200 0 16]
print ["RGB2HSL:" b: rgbToHsl 200 0 16]			
print ["HSL2RGB:" hslToRgb b/1 b/2 b/3]	