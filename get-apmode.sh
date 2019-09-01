#!/bin/sh

PID_FILE='/tmp/get-ap.pid'
HOSTAPD_PID='/tmp/hostapd.pid'
HOSTAPD_CONF='/etc/hostapd/hostapd.conf'

start_ap() {
    echo $$ > $PID_FILE
    #~ echo "Starting ap mode..."
    #~ if [ ! -f /tmp/wmt_loader.lock ]; then
        #~ /usr/bin/wmt_loader
        #~ touch /tmp/wmt_loader.lock
        #~ sleep 3
    #~ else
        #~ echo 'Looks like wmt_loader is runned'
    #~ fi
    #~ echo "Starting stp_uart_launcher..."
    #~ /usr/bin/stp_uart_launcher -p /etc/firmware &
    #~ sleep 3
    #~ echo "Starting stp_uart_launcher - done"
    echo "Going to enable ap mode..."
    echo "Waiting for wmtWifi device..."
    while [ ! -c /dev/wmtWifi ] && [ ! $(pgrep -f stp_uart_launcher) ]; do
        echo '/dev/wmtWifi is not yet available...'
        sleep 2
    done
    sleep 2
    echo '/dev/wmtWifi now is available!'
    echo A >/dev/wmtWifi
    if [ $? -eq 0 ]; then
        echo "Going to enable ap mode - done"
    else
        exit 3
    fi
    sleep 2
    #~ echo 'stp_uart_launcher in background!'
    echo 'Starting hostapd'
    /usr/sbin/hostapd -B -P $HOSTAPD_PID $HOSTAPD_CONF && echo 'Starting hostapd done'
    echo "Enter to background"
    while true; do
        sleep 10
    done
}

stop_ap() {
    echo 'killing hostapd...'
    if [ -f $HOSTAPD_PID ]; then
        hostapd_process=`cat $HOSTAPD_PID`
        echo "PID of hostapd_process is $hostapd_process"
        kill $hostapd_process || kill -9 $hostapd_process
    else
        echo '/tmp/hostapd.pid not found! Continue...'
    fi
    echo 'Killing current script process...'
    if [ -f $PID_FILE ]; then
        current_pid=`cat $PID_FILE`
        kill $current_pid || kill -9 $current_pid
        rm $PID_FILE
        echo 'killing current script process... done'
    else
        echo 'pid file not found! Continue...'
    fi
    echo "Disabling ap mode and reseting wi-fi device..."
    if [ -c /dev/wmtWifi ]; then
        echo 0 >/dev/wmtWifi || echo 'Looks strange. Hmmmm'
        #~ echo "Disabling ap mode - done"
    else
        echo "ERR: /dev/wmtWifi: No such file"
        exit 2
    fi
    #~ echo "Check if stp_uart_launcher is running..."
    #~ pgrep stp_uart_launcher
    #~ if [ $? != 0 ]; then
        #~ echo "stp_uart_launcher not running"
    #~ else
        #~ echo "stp_uart_launcher is running. Lets kill him!"
        #~ kill `pgrep stp_uart_launcher` || kill -9 `pgrep stp_uart_launcher`
        #~ echo "Done!"
    #~ fi
}

case $1 in
    start)
        start_ap
        ;;
    stop)
        stop_ap
        ;;
esac
