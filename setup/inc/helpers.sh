check_last_task() {
    if [ $? -eq 0 ]; then
        echo "OK"
    else
        echo "ERROR"
    fi
}