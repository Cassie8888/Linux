#!bin/bash

# 支持命令行参数方式使用不同功能
function Operations {
    echo "Usage:    bash task2.sh [OPTION...]"
    echo "the options:"
    echo "-a    show the data of the players at different ages"
    echo "-p    show the data of the players in different positions"
    echo "-n    show the data of the players who have the longest or shortest names"
    echo "-m    show the data of the players who are the oldest or the youngest"
    echo "-h    show the help of the operations"
}

# 统计不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员数量、百分比
function compareAge {
    sum=0
    bl20=0
    bt=0
    by30=0
    agecol="\$"6
	# "$1"调用文件名参数
    age=($(awk -F '\t' "{print $agecol}" "$1" ))&& unset age[0]
    for p in "${age[@]}"; do
        if [[ "$p" -lt "20" ]]; then
            bl20=$(($bl20+1))
        elif [[ "$p" -gt "30" ]]; then
            by30=$(($by30+1))
        else
            bt=$(($bt+1))
        fi
        sum=$(($sum+1))
    done
    echo "Sum     : $sum"
    echo "Age             |Percentage"
    echo "< 20    : $bl20     |rate : $(echo $bl20 $sum |awk '{printf "%0.2f\n" ,$1/$2*100}')%"
    echo "[20,30] : $bt   |rate : $(echo $bt $sum |awk '{printf "%0.2f\n" ,$1/$2*100}')%"
    echo "> 30    : $by30   |rate : $(echo $by30 $sum |awk '{printf "%0.2f\n" ,$1/$2*100}') %"
}

# 年龄最大的球员是谁？年龄最小的球员是谁？
function showAges {
    youngest=100
    oldest=0
    count=1
    agecol="\$"6
    namecol="\$"9
    age=($(awk -F '\t' "{print $agecol}" "$1" ))&& unset age[0]
	# 找到最大和最小的年龄
    for p in "${age[@]}"; do
        if [[ "$p" -le "$youngest" ]]; then
            youngest="$p"   
        elif [[ "$p" -gt "$oldest" ]]; then
              oldest=$p
        fi
        count=$(($count+1))
    done
    echo "The youngest age is : $youngest "
    echo "The youngest players are : "
    count=1
	# 根据最小年龄匹配到最年轻的球员
    for m in "${age[@]}"; do
        if [[ "$m" -eq "$youngest" ]]; then 
            yplayer=$(awk -F '\t' "NR==(($count+1)){print $namecol}" "$1")
            echo "$yplayer"   
        fi
        count=$(($count+1))
    done
    echo ""
    echo "The oldest age is : $oldest "
    echo "The oldest players are : "
    count=1
	# 根据最大年龄匹配到最年长的球员
    for m in "${age[@]}"; do
        if [[ "$m" -eq "$oldest" ]]; then 
            oplayer=$(awk -F '\t' "NR==(($count+1)){print $namecol}" "$1")
            echo "$oplayer"   
        fi
        count=$(($count+1))
    done
}

# 统计不同场上位置的球员数量、百分比
function showPositions {
    declare -A a
    positioncol="\$"5
    position=($(awk -F '\t' "{print $positioncol}" "$1" ))&& unset position[0]
    count=0
    for p in "${position[@]}"; do
        if [[ ${a[$p]} ]]; then
            a[$p]=$((${a[$p]}+1))
        else a[$p]=1
        fi
        count=$(($count+1))
    done    
    for k in ${!a[@]}; do 
        echo "$k : ${a[$k]} , percentage is $(echo ${a[$k]} $count |awk '{printf "%0.2f\n" ,$1/$2*100}')%"
    done  
}

# 名字最长的球员是谁？名字最短的球员是谁？
function compareName {
    namecol="\$"9
    nameLength=$( awk -F '\t' "{print length($namecol)}" $1)
    count=0
    longest=0
    shortest=30
    for l in $nameLength; do 
        if [[ $l -gt $longest ]]; then
            longest="$l"
        fi
        if [[ $l -lt $shortest ]]; then
            shortest="$l"
        fi
        count=$(($count+1))
    done
    echo "The longest names are : "
    count=0
    for x in $nameLength; do
        if [[ $x -eq $longest ]]; then
            lname=$(awk -F '\t' "NR==(($count+1)){print $namecol}" "$1")
            echo "$lname"
        fi
        count=$(($count+1))
    done
    echo ""
    echo "The shortest names are : "
    count=0
    for x in $nameLength; do
        if [[ $x -eq $shortest ]]; then
            sname=$(awk -F '\t' "NR==(($count+1)){print $namecol}" "$1")
            echo "$sname"
        fi
        count=$(($count+1))
    done
}
# 主函数
if [ "$#" == 0 ]
then
    Operations
fi

while [ "$1" != "" ];do
    case "$1" in
        "-a" )
            compareAge "worldcupplayerinfo.tsv"
            shift ;;
        "-m" )
            showAges "worldcupplayerinfo.tsv"
            shift ;;
        "-p" )
            showPositions "worldcupplayerinfo.tsv"
            shift ;;
        "-n" )
            compareName "worldcupplayerinfo.tsv"
            shift ;;
        "-h" )
            Operations
            exit 0
    esac
done