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

The simple markov chain experiment can be run with
modelIdentificationValidation/simpleMarkovChainSeveral.R

The results in table 1 can be found in 
modelIdentificationValidation/output/simpleMarkovTest/normalParams1
modelIdentificationValidation/output/simpleMarkovTest/PFAuTable1

The transition matrix in Eq. 10 can be found in 
modelIdentificationValidation/output/simpleMarkovTest/transitionMatrix1

The different experiments for each macro state of the video decompression test can be run with
modelIdentificationValidation/videoDecompressionTestMS1.R
modelIdentificationValidation/videoDecompressionTestMS2.R
modelIdentificationValidation/videoDecompressionTestMS3.R
modelIdentificationValidation/videoDecompressionTestMS4.R

The results in table 2 can be found in
modelIdentificationValidation/output/videoDecompressionMS1/normalParams1
modelIdentificationValidation/output/videoDecompressionMS1/PFAuTable1

The results in table 3 can be found in
modelIdentificationValidation/output/videoDecompressionMS2/normalParams1
modelIdentificationValidation/output/videoDecompressionMS2/PFAuTable1

The results in table 4 can be found in
modelIdentificationValidation/output/videoDecompressionMS3/normalParams1
modelIdentificationValidation/output/videoDecompressionMS3/PFAuTable1

The results in table 5 can be found in
modelIdentificationValidation/output/videoDecompressionMS4/normalParams1
modelIdentificationValidation/output/videoDecompressionMS4/PFAuTable1

For running the entire chain from the trace files:
1. generate the report files (on a linux system with trace-cmd)
simpleMarkov/simpleMarkovTraceReports.sh
videoDecompression/videoDecompressionTraceReports.sh
2. extract execution time data from the report files
exportTimingData/exportDataToCSVSimpleMarkov.py
exportTimingData/exportDataToCSVVideoDecompression.py
3. Run the experiments as described above

After running the experiments, figures can be generated with 
- modelIdentificationValidation/visualizeMarkov.R
Fig. 1 can be found in 
modelIdentificationValidation/output/simpleMarkovChainSeq.png
modelIdentificationValidation/output/simpleMarkovChainSeq.eps

- modelIdentificationValidation/generateGeneralMidFigures.R
Fig. 2 can be found in 
modelIdentificationValidation/output/VideoExecutionTimeTestSeqLog.png
modelIdentificationValidation/output/VideoExecutionTimeTestSeqLog.eps

- modelIdentificationValidation/generateMarkovChainModelFigures.R
Fig 4 a can be found in 
modelIdentificationValidation/output/simpleMarkovTest/simpleMarkovModel1.png
modelIdentificationValidation/output/simpleMarkovTest/simpleMarkovModel1.eps
Fig 4 b can be found in 
modelIdentificationValidation/output/simpleMarkovTest/simpleMarkovModel9.png
modelIdentificationValidation/output/simpleMarkovTest/simpleMarkovModel9.eps

Tests have been made on RStudio version 1.1.456 with 
- R version 3.6.1
- depmixS4 version 1.4.0
- data.tree version 0.7.11
- ggplot2 version 3.2.1