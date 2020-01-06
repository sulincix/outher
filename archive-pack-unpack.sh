
unpacked(){
	while read line
	do
		if echo $line | grep -v "^----.*----$" >/dev/null
		then
			echo $line >> /tmp/tmpfile
		else
			name=$(echo $line | sed "s/^----//g" | sed "s/----$//g")
			echo "Unpacking: $name"
			cat /tmp/tmpfile | base64 -d > $name.x
			rm -f /tmp/tmpfile
			touch /tmp/tmpfile
		fi
	done < $1
}
add_packed(){
	cat "$1" | base64 >> "$2"
	echo "----$1----" >> "$2"
}

if [ "$1" == "create" ] || [ "$1" == "c" ]
then
	i=$3
	for i in $*
	do
		if [ $i != $1 ] && [ $i != $2 ]
		then
			echo "Adding: $i"
			add_packed $i $2
		fi
	done
elif [ "$1" == "extract" ] || [ "$1" == "x" ]
then
	unpacked $2
else
	echo -e "\033[32;1mUsage: \033[35;1m$0\033[;0m [a/c/x] file"
fi

