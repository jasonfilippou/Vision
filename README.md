Vision
======

MATLAB implementations of various popular Computer Vision algorithms and tasks. The entirety of the code was authored for completing the requirements
of CMSC733, UMD's graduate-level Computer Vision course, during the Fall 2014 semester (URL: http://www.cs.umd.edu/~djacobs/CMSC733/CMSC733_14.htm).

### Directory structure

All directories contain local README files which explain how to read and run the source code in detail.

* Canny: Contains an implementation of the popular Canny Edge Detector, as well as relevant documentation.
* Texture Synthesis: Implements the Texture Synthesis algorithm of Efros and Leung.
* Ncut: Implements the Normalized Cut algorithm of Shi and Malik for the problem of segmenting 2D point sets.
* Mosaic: Implements image mosaicing with RANSAC on top of SIFT-matched image keypoints. 
* Stereo: Implements stereo matching with graph cuts, as described in the paper of Boykob, Vekslek and Zabih "Fast approximate energy minimization via graph cuts".
* BoVW: Multi-class classification on the Caltech 101 dataset using Bags-of-Visual Words. 

### Code Dependencies

All code has been implemented in MATLAB, and has been tested with R2014b, on both Linux and Windows 64 bit. MATLAB's Image Processing toolbox is required
for all of the algorithms, except for Ncut. Some programs (Mosaic, Stereo, BoVW) use MEX wrappers to compile C code to use from within MATLAB, so you will
need a C/C++ compiler to compile and link them. 

###Contact

Contact Jason Filippou (jasonfil@cs.umd.edu) with any questions or concerns.
