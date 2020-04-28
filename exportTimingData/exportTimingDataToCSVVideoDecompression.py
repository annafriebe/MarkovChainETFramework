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
    executionTimes = executionTimes[250:len(executionTimes)-50]

    stateTimesFileName = outputBaseFileName + '.csv'
    with open(stateTimesFileName, 'w', newline='') as f:
        timeswriter = csv.writer(f, delimiter=',')
        timeswriter.writerow(("executionTime",))
        for j in range(len(executionTimes)):
            timeswriter.writerow((executionTimes[j],))
    stateTimesFileName = outputBaseFileName + 'MS1' + '.csv'
    with open(stateTimesFileName, 'w', newline='') as f:
        timeswriter = csv.writer(f, delimiter=',')
        timeswriter.writerow(("executionTime",))
        for j in range(len(executionTimes)):
            if (executionTimes[j] < 150000):
                    timeswriter.writerow((executionTimes[j],))
    stateTimesFileName = outputBaseFileName + 'MS2' + '.csv'
    with open(stateTimesFileName, 'w', newline='') as f:
        timeswriter = csv.writer(f, delimiter=',')
        timeswriter.writerow(("executionTime",))
        for j in range(len(executionTimes)):
            if ((executionTimes[j] >= 150000) and (executionTimes[j] < 1000000)):
                    timeswriter.writerow((executionTimes[j],))
        
    stateTimesFileName = outputBaseFileName + 'MS3' + '.csv'
    with open(stateTimesFileName, 'w', newline='') as f:
        timeswriter = csv.writer(f, delimiter=',')
        timeswriter.writerow(("executionTime", ))
        for j in range(len(executionTimes)):
            if ((executionTimes[j] >= 1000000) and (executionTimes[j] < 22500000) ):
                timeswriter.writerow((executionTimes[j],))
        
    stateTimesFileName = outputBaseFileName + 'MS4' + '.csv'
    with open(stateTimesFileName, 'w', newline='') as f:
        timeswriter = csv.writer(f, delimiter=',')
        timeswriter.writerow(("executionTime",))
        for j in range(len(executionTimes)):
            if ((executionTimes[j] >= 22500000) ):
                timeswriter.writerow((executionTimes[j],))
        
        
exportTimingDataToCSV('../videoDecompression/traceVideoTestReport', '../modelIdentificationValidation/input/videoStateTimesTest', 'ffmpeg')