/*  cc_II2Img

  Description:
    This function computes an image (Img) from the input integral image (II).
    The resulting image size depends of the input cell size.

  input:
    prhs[0] <- input integral image (II)
    prhs[1] <- cell size
  output:
    plhs[0] -> image
  
  Contact:
    Michael Villamizar
    mvillami@iri.upc.edu
    Institut de robòtica i informàtica industrial CSIC-UPC
    Barcelona - Spain
    2014

*/

#include <math.h>
#include "mex.h"
#include <stdio.h>

// function
static inline int min(int x, int y) { return (x <= y ? x : y); }

// main function
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) { 

	// check
	if(nrhs!=2) 
   	mexErrMsgTxt("Two inputs required: 1. integral image 2. cell size");
  	if(nlhs!=1) 
    	mexErrMsgTxt("One output required.");

	// integral image (II)
	double *II = (double *)mxGetPr(prhs[0]);
	const int *imgSize = mxGetDimensions(prhs[0]);

	// num. image dimensions
	int numDims = mxGetNumberOfDimensions(prhs[0]);

	// image size
	int sy = imgSize[0];
	int sx = imgSize[1];

	// num. image channels
	int numChannels;
	if (numDims==3){	
		numChannels = imgSize[2];
	}
	else {
		numChannels = 1;
	}

	// cell size
	int cell = (int)mxGetScalar(prhs[1]);

	// output image size
	int ny = (int)ceil((double)(sy)/(double)cell)-1;
	int nx = (int)ceil((double)(sx)/(double)cell)-1;

	// output data
	if (numDims==3){	
		// image		
		int out[3];
		out[0]  = ny;
		out[1]  = nx;
		out[2]  = numChannels;
		plhs[0] = mxCreateNumericArray(3, out, mxDOUBLE_CLASS, mxREAL);
	}
	else {
		// image
		int out[2];
		out[0]  = ny;
		out[1]  = nx;
		plhs[0] = mxCreateNumericArray(2, out, mxDOUBLE_CLASS, mxREAL);
	}
	double *img = (double *)mxGetPr(plhs[0]);

	// variables 
	int left,right,bottom,top;
	
	// image
	for (int x=0; x<nx; x++) {
		
		// current region coordinates
		left  = x*cell;
		right = min(left+cell,sx-1);

		for (int y=0; y<ny; y++) {
		
			// current region coordinates
			top    = y*cell;
			bottom = min(top+cell,sy-1);

			// channels		
			for (int c=0; c<numChannels; c++){
				*(img + y + x*ny + c*nx*ny) = *(II + bottom + right*sy + c*sy*sx) + *(II + top + left*sy + c*sy*sx) - *(II + top + right*sy + c*sy*sx) - *(II + bottom + left*sy + c*sy*sx);
*(img + y + x*ny + c*nx*ny) = *(img + y + x*ny + c*nx*ny)/((double)cell*(double)cell);
			}
		}
	}
}
