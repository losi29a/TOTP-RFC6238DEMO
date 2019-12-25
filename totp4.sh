#!/bin/bash
clear
echo "TOTP RFC6238 Demo by Losi"
b32_key="WK3LC2UK7OAIOXUM6YEJWTGN7U"
declare -A b32
b32=(["A"]=0 ["B"]=1 ["C"]=2 ["D"]=3 ["E"]=4 ["F"]=5 ["G"]=6 ["H"]=7 ["I"]=8 ["J"]=9 ["K"]=10 ["L"]=11 ["M"]=12 ["N"]=13 ["O"]=14 ["P"]=15 ["Q"]=16 ["R"]=17 ["S"]=18 ["T"]=19 ["U"]=20 ["V"]=21 ["W"]=22 ["X"]=23 ["Y"]=24 ["Z"]=25 ["2"]=26 ["3"]=27 ["4"]=28 ["5"]=29 ["6"]=30 ["7"]=31)
D2B=({0..1}{0..1}{0..1}{0..1}{0..1})

bit_string=""
echo -e "A kulcs base32 encodeolva:\033[31m $b32_key \033[0m"
b32kl=${#b32_key}
echo -e "A kulcs hossza base32-ben:\033[31m $b32kl \033[0m"

#base32->binaris konverzio
for (( i=0; i<${#b32_key}; i++ )); do
 
  yyy=${b32_key:$i:1}
  yyy2=${b32[$yyy]}
  yyy3=${D2B[$yyy2]}
  bit_string="$bit_string$yyy3"
done

echo "A kulcs binárisan:"
echo -e "\e[34m$bit_string \033[0m"
echo -e "Bináris hossza: \e[34m ${#bit_string} \033[0m"

#binaris->hexa konverzio az OpenSSL-nek megadhatjuk hexa formátumban a kulcsot

hex_string=""
for (( i=0; i<${#bit_string}; i=i+4 )); do
# echo "${bit_string:$i:4}"
  zzz=${bit_string:$i:4}
  zzz2=$(printf '%x\n' "$((2#$zzz))")
# printf '%x\n' "$((2#$zzz))"
  zzz3=${#zzz}
# echo $zzz3
if (( $zzz3 == 4 )); then 
  hex_string="$hex_string$zzz2"
fi
done

echo -e "A kulcs hexaban: \e[32m $hex_string \033[0m"
echo -e "A kulcs hossza hexaban: \e[32m ${#hex_string} \033[0m"



dec=$(expr $(date +%s) / 30)
hex=$(printf '%x\n' $dec)
zer="000000000"
ld="\x"
hpz="$zer$hex"
echo -e "A Unix timestamp osztva 30-al decimálisan:\e[93m $dec  \033[0m"
echo -e "A Unix timestamp osztva 30-al hexában:\e[93m $hex  \033[0m"
echo -e "Kiegészítve az elején a szükséges nullákkal, hogy 8 byte hosszú legyen:\e[93m $hpz  \033[0m"
hhpz=$(echo $hpz | sed 's/.\{2\}/&\\\x/g')
hhpz="$ld$hhpz"
kama=${hhpz::-2}
echo -n "Végül bytestringként ugyanez az OpenSSL számára:"
echo -e -n "\e[93m"
echo $kama
echo -e -n "\033[0m"

string0=$(echo -n -e $kama | openssl dgst -sha1 -mac hmac -macopt hexkey:$hex_string)
string1=$(echo $string0 | cut -c 9-)
string2=$(( 16#$(echo $string0 |  grep -o '.\{1\}$') ))
num=2
num2=1
string3=$((string2*num))
string3=$((string3+num2))
echo -e "HMAC-SHA1 a kulccsal és a UNIX timestamp/30-al mint üzenet:\e[95m $string1 \033[0m"
echo -e "Offszet (az előző sor legutolsó hexa számjegyéből):\e[95m $string2 \033[0m"
#echo -e "n th char:\e[95m $string3 \033[0m"
string4=$(echo ${string1:$string3:8})
pre="0x"
string411="$pre$string4"
string412="0x7fffffff"
let RE="$string411 & $string412"
string5=$(echo $(( 16#$string4 )))
string6=${RE:(-6)}
echo -e "Dynamic truncation:\e[95m $string4 \033[0m"
echo -n "Dynamic truncation, legnagyobb helyiértékű bit kinullázva "
echo -e -n "\e[95m"
printf '%x\n' $RE
echo -e -n "\033[0m"
echo -e "Ugyanez decimálisan:\e[95m $RE \033[0m "
echo -e "Az utolsó 6 számjegy (maga a TOTP):\e[1;4m $string6 \033[0m"
