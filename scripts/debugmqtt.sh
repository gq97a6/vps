# Get starting number from command line argument
num=0

while true
do
        eval mosquitto_pub -t \"DEBUGAPP\" -m \"$num\" -u \"user\" -P \"abc\"
        sleep 1
        ((num++))
        if [ "$num" -gt 3600 ]; then
            num=0
        fi
done
