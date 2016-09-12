Red [
	Title:   "Random Laws "
	Author:  "Francois Jouen"
	File: 	 %RandomLaws.red
	Needs:	 'View
]

; last Red Master required!
; must be improved bt using a routine

#include %../../libs/redcv.red ; for red functions
margins: 10x10
img1: make image! reduce [100x100 black]
img2: make image! reduce [100x100 black]

view win: layout [
		title "Random Tests"
		origin margins space margins
		button 50 "Float"  [forall img1 [ v1: to integer! (randFloat) * 255
								v2: to integer! (randFloat) * 255
								v3: to integer! (randFloat) * 255
								t: make tuple! reduce [v1 v2 v3] 
								img1/1: t] img2/rgb: sort img1/rgb ]
		button 50 "Uniform" [forall img1 [ v1: to integer! (randUnif 0.5 1.0) * 255
								v2: to integer! (randUnif 0.5 1.0) * 255
								v3: to integer! (randUnif 0.5 1.0) * 255
								t: make tuple! reduce [v1 v2 v3] 
								img1/1: t] img2/rgb: sort img1/rgb]
		button 50 "Exp"  [forall img1 [ v1: (to integer! (randExp) * 255) and 255
								v2: (to integer! (randExp) * 255) and 255
								v3: (to integer! (randExp) * 255)  and 255
								t: make tuple! reduce [v1 v2 v3] 
								img1/1: t] img2/rgb: sort img1/rgb]
		button 50 "Exp /l" [forall img1 [ v1: (to integer! (randExpm 1.0)* 255) and 255
								v2: (to integer! (randExpm 1.0) * 255) and 255
								v3: (to integer! (randExpm 1.0) * 255)  and 255
								t: make tuple! reduce [v1 v2 v3] 
								img1/1: t]img2/rgb: sort img1/rgb]
		button 50 "Normal"[forall img1 [ v1: (to integer! (randNorm 1.0)* 255) and 255
								v2: (to integer! (randNorm 1.0) * 255) and 255
								v3: (to integer! (randNorm 1.0) * 255)  and 255
								t: make tuple! reduce [v1 v2 v3] 
								img1/1: t] img2/rgb: sort img1/rgb]
		button 50 "Gamma" [ forall img1 [ v1: (to integer! (randGamma 1 1.0)* 255) and 255
								v2: (to integer! (randGamma 1 1.0) * 255) and 255
								v3: (to integer! (randGamma 1 1.0) * 255)  and 255
								t: make tuple! reduce [v1 v2 v3] 
								img1/1: t ]img2/rgb: sort img1/rgb
							]
		button 50 "Chi-2"[forall img1 [ v1: (to integer! (randChi2 2)* 255) and 255
								v2: (to integer! (randChi2 2) * 255) and 255
								v3: (to integer! (randChi2 2) * 255)  and 255
								t: make tuple! reduce [v1 v2 v3] 
								img1/1: t ]img2/rgb: sort img1/rgb]
		button 50 "Erlang" [forall img1 [ v1: (to integer! (randErlang 2)* 255) and 255
								v2: (to integer! (randErlang 2) * 255) and 255
								v3: (to integer! (randErlang 2) * 255)  and 255
								t: make tuple! reduce [v1 v2 v3] 
								img1/1: t ]img2/rgb: sort img1/rgb]
		button 50 "Student" [forall img1 [ v1: (to integer! (randStudent 3 1.0) * 255) and 255
								v2: (to integer! (randStudent 3 1.0) * 255) and 255
								v3: (to integer! (randStudent 3 1.0) * 255)  and 255
								t: make tuple! reduce [v1 v2 v3] 
								img1/1: t ]img2/rgb: sort img1/rgb]
		button 50 "Laplace" [forall img1 [ v1: (to integer! (randLaplace 1.0) * 255) and 255
								v2: (to integer! (randLaplace 1.0)* 255) and 255
								v3: (to integer! (randLaplace 1.0) * 255)  and 255
								t: make tuple! reduce [v1 v2 v3] 
								img1/1: t ]img2/rgb: sort img1/rgb]
		button 50 "Weibull" [forall img1 [ v1: (to integer! (randWeibull 1.0 1.0) * 255) and 255
								v2: (to integer! (randWeibull 1.0 1.0)* 255) and 255
								v3: (to integer! (randWeibull 1.0 1.0) * 255)  and 255
								t: make tuple! reduce [v1 v2 v3] 
								img1/1: t ]img2/rgb: sort img1/rgb]
		
		button "Quit" [Quit]
		
		return
		button 50 "Bernouilli"  [forall img1 [ v1: to integer! (randBernouilli 0.5) * 255
								t: make tuple! reduce [v1 v1 v1] 
								img1/1: t] img2/rgb: sort img1/rgb ]
		button 50 "Binomial"  [forall img1 [ v1: to integer! (randBinomial 1 0.5) * 255
								t: make tuple! reduce [v1 v1 v1] 
								img1/1: t] img2/rgb: sort img1/rgb ]
		button 50 "Neg Bin"  [forall img1 [ v1: (to integer! (randBinomialneg 1 0.5) * 255) and 255
								t: make tuple! reduce [v1 v1 v1] 
								img1/1: t] img2/rgb: sort img1/rgb ]
		button 50 "Geo"  [forall img1 [ v1: (to integer! (randGeo 0.25) * 255) and 255
								t: make tuple! reduce [v1 v1 v1] 
								img1/1: t] img2/rgb: sort img1/rgb ]
		button 50 "Poisson"  [forall img1 [ v1: (to integer! (randPoisson 1.0) * 255) and 255
								t: make tuple! reduce [v1 v1 v1] 
								img1/1: t] img2/rgb: sort img1/rgb ]
		return
		
		canvas: base 400x400 img1
		canvas2: base 400x400 img2
		
]

