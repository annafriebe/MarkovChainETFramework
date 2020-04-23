echo  performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo  performance > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo  performance > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo  performance > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor

echo '1-1' | tee /sys/bus/usb/drivers/usb/unbind

taskset -c 1 trace-cmd record -e sched -o traces/traceTrain.dat taskset -c 3 ./simpleMarkovPeriodic
taskset -c 1 trace-cmd record -e sched -o traces/trace1.dat taskset -c 3 ./simpleMarkovPeriodic
taskset -c 1 trace-cmd record -e sched -o traces/trace2.dat taskset -c 3 ./simpleMarkovPeriodic
taskset -c 1 trace-cmd record -e sched -o traces/trace3.dat taskset -c 3 ./simpleMarkovPeriodic
taskset -c 1 trace-cmd record -e sched -o traces/trace4.dat taskset -c 3 ./simpleMarkovPeriodic
taskset -c 1 trace-cmd record -e sched -o traces/trace5.dat taskset -c 3 ./simpleMarkovPeriodic
taskset -c 1 trace-cmd record -e sched -o traces/trace6.dat taskset -c 3 ./simpleMarkovPeriodic
taskset -c 1 trace-cmd record -e sched -o traces/trace7.dat taskset -c 3 ./simpleMarkovPeriodic
taskset -c 1 trace-cmd record -e sched -o traces/trace8.dat taskset -c 3 ./simpleMarkovPeriodic
taskset -c 1 trace-cmd record -e sched -o traces/trace9.dat taskset -c 3 ./simpleMarkovPeriodic
taskset -c 1 trace-cmd record -e sched -o traces/trace10.dat taskset -c 3 ./simpleMarkovPeriodic
taskset -c 1 trace-cmd record -e sched -o traces/trace11.dat taskset -c 3 ./simpleMarkovPeriodic
taskset -c 1 trace-cmd record -e sched -o traces/trace12.dat taskset -c 3 ./simpleMarkovPeriodic
taskset -c 1 trace-cmd record -e sched -o traces/trace13.dat taskset -c 3 ./simpleMarkovPeriodic
taskset -c 1 trace-cmd record -e sched -o traces/trace14.dat taskset -c 3 ./simpleMarkovPeriodic
taskset -c 1 trace-cmd record -e sched -o traces/trace15.dat taskset -c 3 ./simpleMarkovPeriodic
taskset -c 1 trace-cmd record -e sched -o traces/trace16.dat taskset -c 3 ./simpleMarkovPeriodic
taskset -c 1 trace-cmd record -e sched -o traces/trace17.dat taskset -c 3 ./simpleMarkovPeriodic
taskset -c 1 trace-cmd record -e sched -o traces/trace18.dat taskset -c 3 ./simpleMarkovPeriodic
taskset -c 1 trace-cmd record -e sched -o traces/trace19.dat taskset -c 3 ./simpleMarkovPeriodic
taskset -c 1 trace-cmd record -e sched -o traces/trace20.dat taskset -c 3 ./simpleMarkovPeriodic

echo '1-1' | tee /sys/bus/usb/drivers/usb/bind

