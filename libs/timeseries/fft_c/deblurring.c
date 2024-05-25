/* deblur_V.c */
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "mypgm.h"
#include "FFT1.h"
#include "FFT2.h"

#define V_SHIFT 8
#define SIGMA 0.01

void PSF_vertical_blurring()
/* DFT calculation of PSF for vertical blurring */
{
  int i, j, new_size = 1;
  double value = 1.0 / (double)(2 * V_SHIFT + 1);
  
  while (1) {
    new_size *= 2;
    if (new_size >= x_size1 && new_size >= y_size1) break;
  }
  
  num_of_data = new_size;
  
  /* PSF generation for vertical blurring */
  for (j = 0; j < num_of_data; j++) {
    for (i = 0; i < num_of_data; i++) {
      data[j][i] = 0.0;
      jdata[j][i] = 0.0;
    }
  }
  
  for (i = -V_SHIFT; i <= V_SHIFT; i++) {
    j = (i + num_of_data) % num_of_data;
    data[j][0] = value;
  }
  
  /* FFT of PSF is generated and stored into data2 & jdata2 */
  FFT2(1);
  
  for (j = 0; j < num_of_data; j++) {
    for (i = 0; i < num_of_data; i++) {
      data2[j][i] = data[j][i];
      jdata2[j][i] = jdata[j][i];
    }
  }
}


void least_squares_filtering( )
/* deblurring of image data */
/* by using least-squares filtering in DFT space */
/* input: image1[y][x] -------- output: image2[y][x]   */
{
  int i, j;
  double norm, div;
  double wk1, wk2;
  
  /* least-squares filtering */
  /* calculation of inverse filter */
  for (j = 0; j < num_of_data; j++) {
    for (i = 0; i < num_of_data; i++) {
      norm = pow(data2[j][i], 2) + pow(jdata2[j][i], 2);
      div = norm + 2.0 * pow(SIGMA, 2);
      wk1 = data[j][i];
      wk2 = jdata[j][i];
      data[j][i] = (data2[j][i] * wk1 + jdata2[j][i] * wk2) / div;
      jdata[j][i] = (data2[j][i] * wk2 - jdata2[j][i] * wk1) / div;
    }
  }
}


main( )
{
  load_image_data( );           /* Input image load      */
  PSF_vertical_blurring();      /* PSF for blurring */
  make_original_data( );        /* FFT arrays generation   */
  FFT2(1);                      /* 2-d FFT  */
  least_squares_filtering();    /* least-squares filtering */
  FFT2(-1);                     /* 2-d inverse FFT */
  make_output_image( );         /* Image generation after IFFT */
  save_image_data( );           /* Output image save */
  return 0;
}