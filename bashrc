echo "GNU Linux [ Sürüm $(uname -r) ]"
echo "Telif Hakkı <c> 2019 Sulin GNU/Linux. Tüm hakları açıktır."
echo ""
sbrc(){
        echo "C:"$PWD | sed 's/\//\\\\/g'
}

PS1="$(sbrc)> "
