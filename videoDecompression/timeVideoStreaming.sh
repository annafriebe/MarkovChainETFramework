echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor

echo '1-1' | tee /sys/bus/usb/drivers/usb/unbind

taskset -c 1 trace-cmd record -e sched -o traceVideoTest.dat taskset -c 3 chrt -f 99 ffmpeg -re -i tearsOfSteel.avi -f null /dev/null

echo '1-1' | tee /sys/bus/usb/drivers/usb/bind
