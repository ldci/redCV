#!/usr/local/bin/red-cli
Red [
	Author:  "ldci"
	File: %rgb2hslCli.red
]

do %rgbcmyk.red

print ["RGB Values:" 200 128 16]
print ["RGB2CMYK:" b: rgbToCmyk 200 128 16] 			
print ["CMYK2RGB:" cmykToRgb b/1 b/2 b/3 b/4]	
print ["RGB Values:" 200 0 16]
print ["RGB2CMYK:" b: rgbToCmyk 200 0 16]			
print ["CMYK2RGB:" cmykToRgb b/1 b/2 b/3 b/4]

print ["RGB Values:" 0 0 0]
print ["RGB2CMYK:" b: rgbToCmyk 0 0 0]			
print ["CMYK2RGB:" cmykToRgb b/1 b/2 b/3 b/4]	