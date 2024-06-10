
# Computer Vision with Red Language
## see [http://www.red-lang.org](http://www.red-lang.org) 

![](images/red.ico) ![](images/redCV.png)
### You need a recent Red version. 
### Compiled with Red-toolchain 0.6.5 for macOS.

### Tested with macOS.

Code is functional with Red 0.6.5. Errors corrected for Haar detection.

You must compile samples since red routines are required.
Most of samples require View.

Use first -c compiler option to create a Red RT library and in case of problems use -u compiler option. See [https://www.red-lang.org](https://www.red-lang.org) for details.


**Extra documentation here :** [http://redlcv.blogspot.com/2017/04/blog-post.html](http://redlcv.blogspot.com/2017/04/blog-post.html)

### **UPDATE May 25 2024**
General update adapted to Red 0.6.5.

### **UPDATE SEPTEMBER 1 2021**
Support for Optris Infrared devices added including images and movies samples.

### **UPDATE AUGUST 15 2021**

## redCV version is now 2.0.0

More than **600 routines and functions** for image processing.
 
redCV is fully compatible with the **matrix object** we developed with Toomas Vooglaid and Qingtian Xie during 2020 summer break.

redCV can talk with **Pandore C++ library**.

redCV is completly **modular**.

redCV documentation is **updated**.

redCV code samples also **updated**. 



### UPDATE JANUARY 2 2021
redCV includes a support for Flir themal images. This will be extended to other thermal imagers such as Optris.

### UPDATE NOVEMBER 30 2020
All libs and code samples are compatible with the new less permissive, but faster Red compiler.

This udpate also includes **a new matrix object** developed with Toomas Vooglaid during the last summer in order to improve initial matrix implementation.

You'll find in *libs/matrix/atrix-as-obj/docs* a short and incomplete documentation and some samples.




### UPDATE JULY 15 2020

#### More than 200 code samples documented!

**New libraries for Haar cascade and machine learning**

1. /libs/objdetect/rcvHaarCascade.red
1. /libs/objdetect/rcvHaarRectangles.red

**New libraries for Portable bitmap support**

1. /libs/pbm/rcvPbm.red				

**Modified libraries**

1. /libs/core/rcvCore.red 		
1. /libs/matrix/rcvMatrix.red	
1. /libsimgproc/rcvImgProc.red	
1. /libs/math/rcvStats.red		
1. /libs/math/rcvMoments.red		
1. /libs/math/rcvHistogram.red	
1. /libs/math/rcvDistance.red	
1. /libs/zLib/rcvZLib.red			
1. /libs/tiff/rcvTiff.red	

**New code samples**

1. /image_alpha/blendImage3.red
1. /image_alpha/blendImage4.red
1. /image_alpha/ mask.red
1. /image_compression/compress2.red
1. /image_draw/thread.red
1. /image_Haar/faceDetection.red
1. /image_Haar/camFace.red
1. /image_Haar/xmlCascade.red
1. /image_hog/hog1
1. /image_hog/hog2
1. /image_hog/hog3
1. /image_hog/hog4
1. /image_hog/hog5
1. /image_transformation/imageCrop.red	

**Updated code samples**

1. /image_channel/redCVSplitMerge.red
1. /image_distances/chamfer/chamfer2.red
1. /image_distances/chamfer/flow.red
1. /image_fft/imagefft1.red
1. /image_fft/imagefft2.red
1. /image_fft/imagefft3.red
1. /image_filters/neuman/neuman1.red
1. /image_histograms/colorHisto.red
1. /image_histograms/grayHisto.red
1. /image_histograms/meanShift.red
1. /image_integral/integral3.red
1. /image_operators/opimage.red
1. /image_pixels/pixel1.red
1. /image_pixels/pixel2.red
1. /image_random/randomView.red
1. /video/cam1.red
1. /video/cam2.red
1. /video/cam4.red
1. /video/cam41.red
1. /video/camBin.red
1. /video/camConv.red
1. /video/motion.red
1. /video/tracking1.red
1. /video/tracking2.red

**Obsolete code samples**

see [https://github.com/ldci/ffmpeg](https://github.com/ldci/ffmpeg) for better video access

1. /video/movie.red
1. /video/reccam.red


### UPDATE FEBRUARY 4 2020

### 100% macOS, Windows, and Linux GTK compatible
For Windows and macOS and now Linux-GTK. Thanks to 
@bitbegin, @loziniak and @rcqls. 

**Modified libraries**

1. rcvCore.red
1. rcvImgProc.red
1. rcvMatrix.red
1. rcvStats.red

**Modified samples**

1. /image_alpha/blendImage2.red
1. /image_alpha/blendMatrices.red
1. /image_contours/signaturePolar.red
1. /image_denoising/smoothing.red
1. /image_distances/chamfer/chamfer.red
1. /image_distances/chamfer/chamfer2.red
1. /image_fft/fftLowPass.red
1. /image_pixels/pixel1.red
1. /image_pixels/pixel2.red
1. /image_pixels/wpixel.red
1. /image_random/randomMat.red
1. /image_resizing/pyramidal.red
1. /image_resizing/resize1.red
1. /image_resizing/resize2.red
1. /image_sort/sortimage2.red
1. /image_statistics/imageStats.red
1. /image_transformation/imageScale.red
1. /signal_processing/fourier1.red
1. /signal_processing/fourier2.red
1. /signal_processing/fourier3.red
1. /signal_processing/fourier4.red

### UPDATE JANUARY 28 2020
redCV is now 100% compatible with Linux-GTK.

**modified library modules**

1. /libs/core/rcCore.red
1. /libs/matrix/rcvMatrix.red
1. /libs/timeseries/rcvFFT.red 
1. /libs/tiff/rcvTiff.red

**modified samples**

1. /samples/image_contours/ (all samples)
1. /samples/image_detector/pointDetector.red
1. /samples/image_distance/chamfer/flow.red
1. /samples/image_fft/ (all fourier samples) 
1. /samples/image_pixel/ (pixel1 pixel2)
1. /samples/image_transformation (imageRotate imageSkew imageTranslate imageClip)
1. /sample/signal_processsing/ (all fourier samples)

### UPDATE JANUARY 9 2020
Happy New Year!

**A new version of redCV**.

Most of functions are now defined as routines for a faster image processing and redCV is now *modular*. This means, that you can use only required libraries for your code and not all redCV library. This modular organization reduces compilation duration, reduces the size of the executable applications and, helps in maintaining redCV.As detailed in /libs/redcv.red file, some libraries are mandatory and other are optional according to specific applications. 

*All code samples included in redCV use modular library calling*. Code sample documentation is quite complete.

Updated documentation. New functions and samples, including Fast Fourier Transform.



### UPDATE JULY 22 2019
A lot of important changes before summer break

Updated libs

New functions for image effect. K-means algorithm implemented

New sample directory organization

New documentation including samples documentation (work in progress)


### UPDATE APRIL 25 2019
Updated documentation. New distance functions and samples (/samples/voronoi).

### UPDATE MARCH 25 2019

Updated documentation. New functions and samples.

### UPDATE FEBRUARY 4 2019

Update for red 0.6.4 version

### UPDATE AUGUST 26 2018

Dynamic Time Warping added to redCV.


### UPDATE AUGUST 4 2018
General update for documentation.

General update for code sample.

A lot of new samples are added for lines and shapes detection in image.


### UPDATE FEBRUARY 16 2018
redCV can write tiff images: 24-bit color format.

### UPDATE FEBRUARY 10 2018

redCV can read tiff files now. 1 to 4 channels 8-bit uncompressed images are supported. 
see /samples/tiff for code sample.

Doc is also updated.

### UPDATE JANUARY 20 2018

You'll find in /samples/image_compression/ new code for image compression with ZLib.

Documentation is updated.

### UPDATE JANUARY 04 2018

Happy New Year!

New samples in /video for wrting and reading video files with Red and Camera


### UPDATE DECEMBER 28 2017
Update for video samples according to evolution of red camera object. 

### NEW OCTOBER 4 2017

General update for Red 0.6.3

New samples for distance maps

Documentation is updated

### NEW JULY 4 2017
Added rcvContourArea function and new samples
### NEW JULY 1 2017
Quick Convex Hull algorithm added to RedCV.

Samples and documentation updated. 


### NEW JUNE 22 2017

Most of code (libs and sample) is updated according to Red modifications for Image! datatype. 

New edges detection fast operators are also added.  


### NEW MAY 13 2017

Documentation is reorganized for a better comprehension and includes an **index** of all implemented functions.

New RedCV functions added such as **logarithmic image processing model**.

A lot of new edges filters added in library and in code samples.

### APRIL 1 2017

ImageClip.red and libs updated.


### NEW MARCH 29 2017

RedCV can be used with Red 0.6.2.

New samples added such as clipping functions



### NEW DECEMBER 5 2016

Updated version for samples including B&W filters, histograms and integral image

You have to compile samples with following command:

red -c -t Windows filename.red

### NEW NOVEMBER 14 2016

Integral for matrices and images are added.

See RedCV manual for details.


### NEW NOVEMNBER 12 2016

WARNING: some exe are reported with "TR/Crypt.XPACK.Gen2" infection by Github.

Puzzling since exe are compiled under MacOS, but to avoid any problems all exe are suppressed.

You'll need to compile samples with following command:

red -c -t Windows filename.red

Very easy to do :)


### NEW NOVEMBER 9 2016

Extended morphological operators  and samples added.

Documentation updated.

### NEW NOVEMBER 4 2016

Morphological operators for color images added.

### NEW OCTOBER 18 2016

rcvHistogramEqualization function added in library. 

This very fast function is useful for improving contrast in low-contrasted images or simply modifying the contrast of image.

### NEW OCTOBER 15 2016

Statistical functions improved. See RedCV_Manual documentation for details.

### NEW OCTOBER 14 2016

New samples in /samples/Draw_DSL/ 

This is an illustration of how Draw DSL can be used to create nice graphical applications.

Enjoy 


### NEW OCTOBER 10 2016

rcvScaleImage, rcvTranslateImage and rcvRotateImage are now RedCV Functions.

See RedCV_Manual for details.

Samples and documentation updated.


### NEW OCTOBER 10 2016

Scale, Translate and Rotate operators based on Red Draw Dialect added.

New convolution samples added.


### NEW OCTOBER 5 2016

RedCV Reference Manual replaces basic documentation.

About 150 functions tested and are functional.


### NEW SEPTEMBER 29 2016

New color space conversions added.

rcvInRange function added: Extracts sub array from image according to lower and upper rgb values.

Samples and documentation updated.

### NEW SEPTEMBER 25 2016

Histogram functions for matrices and color images added.

New samples added.

Doc updated.

### NEW SEPTEMBER 21 2016

Statistical functions are rewritten to be used with images and matrices.

rcvMinLoc and rcvMaxLoc functions added: Finds global minimum or maximum location in array.

Doc updataed.

### NEW SEPTEMBER 19 2016

Split and Merge functions for matrices are added.


### NEW SEPTEMBER 12 2016
A lot of optimized functions for working with 8,16 and 32-bit integer matrices.

New samples added.

Documentation updated.

### NEW SEPTEMBER 1 2016
Image resizing and Gaussian Pyramid Decomposition are added with this function: 

rcvResizeImage: function [src [image!] canvas iSize [pair!]/gaussian return: [pair!]]

Only Gaussian 5x5 kernel is currently supported. Canvas is a base facet.
If you don’t call /Gaussian refinement image is just resized by Red.

Documentation updated.


### NEW AUGUST 29 2016

Convolution with integer matrices is now possible. 

Also added  a faster rcvFastConvolve working on separate image channel or grayscaled images. 


### NEW AUGUST 24 2016

Back from summer break with a lot of new samples and functions!

Matrices can be used now with vector! datatype, but we'll wait for the matrix! datatype for improving functions.

New samples folder thematic organization.

Doc is updated.


### NEW JULY 27 2016

gaussianFilter sample updated.


### NEW JULY 26 2016

Slight changes in libs: all red routines begin with underscore (e.g. _rcvCopy).

Documentation updated.

Samples updated.   

New samples added in /samples/test directory.


### NEW July 24 2016

A sample for Gaussian Filter


### NEW July 23 2016

Gaussian filter added (see /samples/test/ testGaussian.red)


### NEW July 18 2016

Convolve routines are improved but rather low speed as expected!

2D Filtering can be used. (see documentation for details)

More samples to come

### NEW July 12 2016

Fast flip render and documentation update

### NEW july 10 2016

#### Documentation for redCV functions added

### NEW july 9 2016

Black and white image filter added.

A new sample (motion.red) for motion tracking with webcam.


### NEW: July 8 2106
A lot of work for this new version with faster routines and functions

Most of functions are in the form rcvFunction [src [image!] dst [image!]] [....]
This avoids memory leaks due to image copy 

New organizations for libs 

All Red/System Routines are in the same file and routines are exported as red functions in the various libs

New basic samples (to be compiled) 

Documentation and new samples will be included ASAP


### NEW: June 28 2016

rcvFlip routines are faster (written in Red/System).

Motion detection sample added : you can use your webcam to do a video monitoring!

Samples are compiled with -t WindowsXP option.


### NEW: June 22 2016
Libs are improved for faster routines.

New convolution samples are included.

Rendering duration is calculated with the new Red timer and sent back to the user.

Special thanks for DideC for interface improvment:)

New folder organisation:

/samples for red code
/samples/_exe for exec files


### NEW: June 17 2016

Convolution routines for images are added.

More to come ...


### NEW: June 15 2016
Added statistical functions on image.

Added some space color conversion.

More to come...


### NEW: June 2016
After playing a long time with OpenCV and Red language, it's time for me to write some image processing functions directly with Red:)

Conversions, logical and some math operators for images are available.


According to KISS spirit of Red, you only need  to include one file in your code : #include %libs/redcv.red.(See opimage.red sample for detail).

This file includes Red Functions and calls all necessary routines. 

More functions and samples to come!

You'll find some images to play within images folder. All supported images by Red can be used.

Special thanks to Nenad for developing Red, and to Qingtian for image implementation.


##Please feel free to contribute and enjoy :)
