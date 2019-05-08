find_files(){
if [ "$2" == "" ]
then
  echo -e "\033[32;1mRegex for all files:\033[;0m" 1>&2
  find "$1" | grep "\."
else
  echo -e "\033[32;1mRegex for \033[;0m\.$2\033[32;1m files:\033[;0m" 1>&2
  find "$1" | grep "\.$2\$"
fi
}

regex(){
file="0"
while [ "$file" != "" ]
do
  read file
  if [ "$file" != "" ]
  then
    echo -e "\033[32;1mFile:\033[;0m$file"
    sed -i "$1" "$file"
  fi
done
}

echo -n -e "\033[32;1mEnter a directory >\033[;0m"
read dir
echo -n -e "\033[32;1mEnter file type >\033[;0m"
read type
echo -n -e "\033[32;1mEnter regex line >\033[;0m"
read line
find_files "$dir" "$type" | regex "$line"


