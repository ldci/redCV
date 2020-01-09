Red [
	Title:   "Random Laws "
	Author:  "Francois Jouen"
	File: 	 %RandomLaws.red
	Needs:	 'View
]

; last Red Master required!
; must be improved bt using a routine

; required libs
#include %../../libs/math/rcvRandom.red

margins: 5x5
img1: make image! reduce [100x100 black]
img2: make image! reduce [100x100 black]

view win: layout [
		title "Random Tests"
		origin margins space margins
		button "Float"  [forall img1 [ 
										v1: to integer! (randFloat) * 255
										v2: to integer! (randFloat) * 255
										v3: to integer! (randFloat) * 255
										t: make tuple! reduce [v1 v2 v3] 
										img1/1: t
									] 
									img2/rgb: sort img1/rgb]
								
		button "Uniform" [forall img1 [ 
										v1: to integer! randUnif 0.5 1.0 * 255
										v2: to integer! randUnif 0.5 1.0 * 255
										v3: to integer! randUnif 0.5 1.0 * 255
										t: make tuple! reduce [v1 v2 v3] 
										img1/1: t
									] 
									img2/rgb: sort img1/rgb]
								
		button "Exp"  [forall img1 [ 
										v1: (to integer! randExp * 255) and 255
										v2: (to integer! randExp * 255) and 255
										v3: (to integer! randExp * 255) and 255
										t: make tuple! reduce [v1 v2 v3] 
										img1/1: t
									] 
									img2/rgb: sort img1/rgb]
								
								
		button  "Exp/l" [forall img1 [ 
										v1: (to integer! (randExpm 1.0) * 255) and 255
										v2: (to integer! (randExpm 1.0) * 255) and 255
										v3: (to integer! (randExpm 1.0) * 255) and 255
										t: make tuple! reduce [v1 v2 v3] 
										img1/1: t
									] 
									img2/rgb: sort img1/rgb]
								
		button  "Normal"[forall img1 [ 
									v1: (to integer! (randNorm 1.0) * 255) and 255
									v2: (to integer! (randNorm 1.0) * 255) and 255
									v3: (to integer! (randNorm 1.0) * 255) and 255
									t: make tuple! reduce [v1 v2 v3] 
									img1/1: t
								] img2/rgb: sort img1/rgb]
								
								
		button "Gamma" [ forall img1 [ 
									v1: (to integer! (randGamma 1 1.0) * 255) and 255
									v2: (to integer! (randGamma 1 1.0) * 255) and 255
									v3: (to integer! (randGamma 1 1.0) * 255) and 255
									t: make tuple! reduce [v1 v2 v3] 
									img1/1: t 
								]img2/rgb: sort img1/rgb
							]
							
		button "Student" [forall img1 [ 
									v1: (to integer! (randStudent 3 1.0) * 255) and 255
									v2: (to integer! (randStudent 3 1.0) * 255) and 255
									v3: (to integer! (randStudent 3 1.0) * 255) and 255
									t: make tuple! reduce [v1 v2 v3] 
									img1/1: t 
								]
								img2/rgb: sort img1/rgb]
								
								
		button "Laplace" [forall img1 [ 
								v1: (to integer! (randLaplace 1.0) * 255) and 255
								v2: (to integer! (randLaplace 1.0)* 255) and 255
								v3: (to integer! (randLaplace 1.0) * 255)  and 255
								t: make tuple! reduce [v1 v2 v3] 
								img1/1: t ]img2/rgb: sort img1/rgb]
							
		button "Chi-2"[forall img1 [ 
									if error? try [v1: (to integer! randChi2 2 ) and 255] [v1: 0]
									if error? try [v2: (to integer! randChi2 2 ) and 255] [v2: 0]
									if error? try [v3: (to integer! randChi2 2 ) and 255] [v3: 0]
									t: make tuple! reduce [v1 v2 v3] 
									img1/1: t 
								]
								img2/rgb: sort img1/rgb]
								
								
		button  "Erlang" [forall img1 [ 
									if error? try [v1: (to integer! (randErlang 1) * 255) and 255] [v1: 0]
									if error? try [v2: (to integer! (randErlang 1) * 255) and 255] [v2: 0]
									if error? try [v3: (to integer! (randErlang 1) * 255) and 255] [v3: 0]
									t: make tuple! reduce [v1 v2 v3] 
									img1/1: t 
								]
								img2/rgb: sort img1/rgb]
								
		
		button "Weibull" [forall img1 [ 
								if error? try [v1: (to integer! (randWeibull 1.0 1.0) * 255) and 255] [v1: 0]
								if error? try [v2: (to integer! (randWeibull 1.0 1.0) * 255) and 255] [v2: 0]
								if error? try [v3: (to integer! (randWeibull 1.0 1.0) * 255) and 255] [v3: 0]
								t: make tuple! reduce [v1 v2 v3] 
								img1/1: t ]
								img2/rgb: sort img1/rgb]
		
		
		return
		
		button  "Bernouilli"  [forall img1 [ v1: to integer! (randBernouilli 0.5) * 255
								t: make tuple! reduce [v1 v1 v1] 
								img1/1: t] img2/rgb: sort img1/rgb ]
		button  "Binomial"  [forall img1 [ v1: to integer! (randBinomial 1 0.5) * 255
								t: make tuple! reduce [v1 v1 v1] 
								img1/1: t] img2/rgb: sort img1/rgb ]
		button  "Neg Bin"  [forall img1 [ v1: (to integer! (randBinomialneg 1 0.5) * 255) and 255
								t: make tuple! reduce [v1 v1 v1] 
								img1/1: t] img2/rgb: sort img1/rgb ]
		button  "Geometric"  [forall img1 [ v1: (to integer! (randGeo 0.25) * 255) and 255
								t: make tuple! reduce [v1 v1 v1] 
								img1/1: t] img2/rgb: sort img1/rgb ]
		button "Poisson"  [forall img1 [ v1: (to integer! (randPoisson 1.0) * 255) and 255
								t: make tuple! reduce [v1 v1 v1] 
								img1/1: t] img2/rgb: sort img1/rgb ]
		
		button "Gaussian" [forall img1 [ v1: (to integer! (randGaussian/x 0.0 1.0) * 255) and 255
								v2: (to integer! (randGaussian/x 0.0 1.0) * 255) and 255
								v3: (to integer! (randGaussian/x 0.0 1.0) * 255) and 255
								t: make tuple! reduce [v1 v2 v3] 
								img1/1: t] 
								img2/rgb: sort img1/rgb ]
		
		pad 222x0
		button "Quit" [Quit]
		return
		
		canvas: base 400x400 img1
		canvas2: base 400x400 img2
		
]

