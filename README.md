# MarkovChainETFramework

Framework for identification and validation of Markov Models with Gaussian Emission Distributions from Execution Time sequences.

The modelIdentificationValidation directory contains R code for 
- finding the number of states in the Markov Model using a tree-based cross-validation approach, methods in modelIdentificationValidation/R/evalLikelihood.R
- evaluating a data consistency criterion for the model compared to observations, using methods in modelidendificationValidation/R/dataConsistencyModelValidation.R

These methods are used with the different test programs in the modelIdentificationValidation folder, for test data in the modelIdentificationValidation/input folder.

The simpleMarkovChain folder contains C++ code for a simple test program with known Markov Chain properties, a script used for running and retrieving timing traces from the compiled executable on a Raspberry Pi 3B+ with Arch Linux ARM patched with PREEMPT_RT, and a script for retrieving trace reports in nanosecond precision from the trace files. The traces are available in the folder simpleMarkovChain/traces.

The videoDecompression folder contains a python script for creating a video from frames from the Tears Of Steel Creative Commons Licensed video (CC) Blender Foundation | mango.blender.org, a script used for decompressing this video with ffmpeg in native frame rate and retrievning a timing trace of this process. The folder also contains the trace file and a script for retrieving a trace report in nanosecond precision from the trace file.

The exportTimingData folder contains python scripts for converting the report files generated in the simpleMarkovChain and videoDecompression folders into .csv files with execution time sequences, that are put in the modelIdentificationValidation/input folder.

The files in the modelIdentificationValidation/input folder are pregenerated, so the tests in modelIdentificationValidation can be run directly, without the steps of generating the reports from the trace files and generating the .csv files from the reports.

