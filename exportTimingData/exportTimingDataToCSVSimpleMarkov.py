# -*- coding: utf-8 -*-
"""
Created on Mon Nov 11 14:13:39 2019

@author: afe02
"""

import numpy as np
import csv
import switchDataForCPU


def timesAsArray(times):
    timesArray = np.zeros(len(times), dtype=int)
    for i in range(len(times)):
        timesArray[i] = times[i]
    return timesArray
    


def exportTimingDataToCSV(filename, outputBaseFileName, processName):
    switchWakeupData = getSwitchAndWakeupDataForCPU(filename, '[003]')

    releaseTimeDict, schedulingTimeDict, executionTimeDict, previousProcessList,\
    wakeupInLatencyProcessList, wakeupInExecutionProcessList = \
        getTimeDicts(switchWakeupData, processName)

    executionTimes = timesAsArray(executionTimeDict['all'])

    executionTimes = executionTimes[250:len(executionTimes)-1]
    stateTimesFileName = outputBaseFileName + '.csv'
    with open(stateTimesFileName, 'w', newline='') as f:
        timeswriter = csv.writer(f, delimiter=',')
        timeswriter.writerow(("executionTime",))
        for j in range(len(executionTimes)):
            timeswriter.writerow((executionTimes[j],))
        
        
exportTimingDataToCSV('../simpleMarkov/reports/simpleMarkovTrainReport', '../modelIdentificationValidation/input/simpleMarkovTimesTrain', 'simpleMarkov')
for i in range(20):
    inputFileName = '../simpleMarkov/reports/simpleMarkovTestReport' + str(i+1)
    outputFileName = '../modelIdentificationValidation/input/simpleMarkovTimesTest' + str(i+1)
    exportTimingDataToCSV(inputFileName, outputFileName, 'simpleMarkov')
    