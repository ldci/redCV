Red [
	Title:   "Red Computer Vision: Image Processing"
	Author:  "Francois Jouen"
	File: 	 %rcvSegmentation.red
	Tabs:	 4
	Rights:  "Copyright (C) 2020 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;**************** Skin Color Segmentation *******************

{Based on: P. Peer, J. Kovac, and F. Solina. 
Human skin colour clustering for face detection. 
International Conference on Computer as a Tool, EUROCON 2003, 
Ljubljana, Slovenia, September 2003.}

rcvSkinColor: routine [
"Skin color segmentation"
    src 	[image!]
    dst  	[image!]
    thresh	[integer!]
    /local
        pixS pixD 					[int-ptr!]
        handleS handleD i n 		[integer!]
        r g b a 					[integer!]
        mini maxi diff				[integer!]
        pixel0 pixel1 rgba rule 	[subroutine!]
][
    handleS: 0
    handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    n: IMAGE_WIDTH(src/size) * IMAGE_HEIGHT(src/size)
    a: 0 r: 0 g: 0 b: 0 mini: 0 maxi: 0 diff: 0
    ;--subroutines for fast execution
    rule: [all [r > 95 g > 40 b > 15 maxi - mini > thresh
    		diff > thresh  r > g r > b]]
    rgba: [
    	a: pixS/value >>> 24
       	r: pixS/value and 00FF0000h >> 16 
        g: pixS/value and FF00h >> 8 
        b: pixS/value and FFh 
    ]
    pixel0: [(a << 24) OR (0 << 16 ) OR (0 << 8) OR 0]
    pixel1: [(a << 24) OR (r << 16 ) OR (g << 8) OR b]
    ;--end of subroutines	
    i: 0
    while [i < n] [
    	rgba
        either r > g [mini: g][mini: r] if b < mini [mini: b]
    	either r > g [maxi: r][maxi: g] if b > maxi [maxi: b]
        diff: r - g  if diff < 0 [diff: 0 - diff]
        ;pixD/value: pixel0 if rule [pixD/value: pixel1]
        either rule [pixD/value: pixel1] [pixD/value: pixel0]
        pixS: pixS + 1
        pixD: pixD + 1
    	i: i + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]
