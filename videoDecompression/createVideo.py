#!/usr/bin/python3.6
import subprocess
start = 5000
nFrames = 4000
for i in range(1, nFrames):
    pathName = "https://media.xiph.org/tearsofsteel/tearsofsteel-1080bis-png/0" + str(i+start) + ".png"
    outputFileName = "frame" + '{:05d}'.format(i) + ".png"
    subprocess.call(["wget", pathName, "-O", outputFileName])
subprocess.call(["ffmpeg",  "-r", "25", "-i", "frame%05d.png", "tearsOfSteel.avi"])
