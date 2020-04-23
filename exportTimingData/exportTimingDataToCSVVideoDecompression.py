# -*- coding: utf-8 -*-
"""
Created on Mon Nov 11 14:13:39 2019

@author: afe02
"""

import numpy as np
import csv
import switchDataForCPU


def periodicAdjustedTimes(times, period, factor = 1):
    periodicAdjustedTimes = np.zeros(len(times))
    for i in range(len(times)):
        periodicAdjustedTimes[i] = ((times[i]* factor) % period) / factor
    return periodicAdjustedTimes

def getTwoProcessStates(previousProcessList, processName):
    states = np.zeros(len(previousProcessList), dtype=int)
    for i in range(len(previousProcessList)):
        process = previousProcessList[i]
        if process.startswith(processName) or process == '':
            states[i] = 0
        else:
            states[i] = 1
    return states

def timesToClockCycles(times, conversionFactor):
    nClockCycles = np.zeros(len(times), dtype=int)
    for i in range(len(times)):
        nClockCycles[i] = (int) (times[i] * conversionFactor + 0.5)
    return nClockCycles



def exportTimingDataToCSV(filename, outputBaseFileName, processName, period):
    switchWakeupData = getSwitchAndWakeupDataForCPU(filename, '[003]')

    releaseTimeDict, schedulingTimeDict, executionTimeDict, previousProcessList,\
    wakeupInLatencyProcessList, wakeupInExecutionProcessList = \
        getTimeDicts(switchWakeupData, processName)
    factor = 1
    allSchedulingTimes = np.zeros(0)
    allReleaseTimes = np.zeros(0)
    factor = 1

    for item in releaseTimeDict:
        releaseTimeDict[item] = periodicAdjustedTimes(releaseTimeDict[item], period, factor)
        if item == 'all':
            allReleaseTimes = releaseTimeDict[item]

    for item in schedulingTimeDict:
        schedulingTimeDict[item] = periodicAdjustedTimes(schedulingTimeDict[item], period, factor)
        if item == 'all':
            allSchedulingTimes = schedulingTimeDict[item]

    schedulingReleaseDiff = allSchedulingTimes - allReleaseTimes

    twoProcesses = getTwoProcessStates(previousProcessList, processName)

    clockCycleConversionFactor = 1
    executionTimes = timesToClockCycles(executionTimeDict['all'], clockCycleConversionFactor)
    wakeUpLatencies = timesToClockCycles(schedulingReleaseDiff, clockCycleConversionFactor)

    executionTimes = executionTimes[250:len(executionTimes)-50]
    wakeUpLatencies = wakeUpLatencies[250:len(wakeUpLatencies)-50]
    twoProcesses = twoProcesses[250:len(twoProcesses)-50]
    stateTimesFileName = outputBaseFileName + '.csv'
    with open(stateTimesFileName, 'w', newline='') as f:
        timeswriter = csv.writer(f, delimiter=',')
        timeswriter.writerow(("executionTime", "wakeUpLatency", "interfered"))
        for j in range(len(executionTimes)):
            timeswriter.writerow((executionTimes[j], wakeUpLatencies[j], twoProcesses[j]))
    stateTimesFileName = outputBaseFileName + 'MS1' + '.csv'
    with open(stateTimesFileName, 'w', newline='') as f:
        timeswriter = csv.writer(f, delimiter=',')
        timeswriter.writerow(("executionTime", "wakeUpLatency", "interfered"))
        for j in range(len(executionTimes)):
            if (executionTimes[j] < 150000):
                    timeswriter.writerow((executionTimes[j], wakeUpLatencies[j], twoProcesses[j]))
    stateTimesFileName = outputBaseFileName + 'MS2' + '.csv'
    with open(stateTimesFileName, 'w', newline='') as f:
        timeswriter = csv.writer(f, delimiter=',')
        timeswriter.writerow(("executionTime", "wakeUpLatency", "interfered"))
        for j in range(len(executionTimes)):
            if ((executionTimes[j] >= 150000) and (executionTimes[j] < 1000000)):
                    timeswriter.writerow((executionTimes[j], wakeUpLatencies[j], twoProcesses[j]))
        
    stateTimesFileName = outputBaseFileName + 'MS3' + '.csv'
    with open(stateTimesFileName, 'w', newline='') as f:
        timeswriter = csv.writer(f, delimiter=',')
        timeswriter.writerow(("executionTime", "wakeUpLatency", "interfered"))
        for j in range(len(executionTimes)):
            if ((executionTimes[j] >= 1000000) and (executionTimes[j] < 22500000) ):
                timeswriter.writerow((executionTimes[j], wakeUpLatencies[j], twoProcesses[j]))
        
    stateTimesFileName = outputBaseFileName + 'MS4' + '.csv'
    with open(stateTimesFileName, 'w', newline='') as f:
        timeswriter = csv.writer(f, delimiter=',')
        timeswriter.writerow(("executionTime", "wakeUpLatency", "interfered"))
        for j in range(len(executionTimes)):
            if ((executionTimes[j] >= 22500000) ):
                timeswriter.writerow((executionTimes[j], wakeUpLatencies[j], twoProcesses[j]))
        
        
exportTimingDataToCSV('../videoDecompression/traceVideoTestReport', '../modelIdentificationValidation/input/videoStateTimesTest', 'ffmpeg', 10000000)