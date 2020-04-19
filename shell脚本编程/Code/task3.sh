#!/bin/bash

# 支持命令行参数方式使用不同功能
function Operations {
    echo "Usage:    bash task3.sh [OPTION...]"
    echo "the options:"
    echo "-sh    display the total number of occurrences of the access TOP 100 source host and each corresponding"
    echo "-si    display the total number of occurrences of the access TOP 100 source IP and each corresponding"
    echo "-ua    show the most frequently accessed TOP 100 URL"
    echo "-rc    show the number of occurrences and corresponding percentages of different response status codes"
    echo "-ux    display the TOP 10 URL corresponding to the different 4XX status codes and the total number of corresponding occurrences"
    echo "-su    Display the TOP 100 access source host given URL"
    echo "-h     get the operations of the script"
}

# 统计访问来源主机TOP 100和分别对应出现的总次数
function topHost {
    cat web_log.tsv | awk -F '\t' '{count[$1]++} END {for(i in count) {print count[i],"times      Host: " i}}' | sort -nrk 1 | head -n 100 >> hostTop100.txt
    echo "Done! The result saved in hostTop100.txt"
}
# 统计访问来源主机TOP 100 IP和分别对应出现的总次数
function topIP {
    cat web_log.tsv | awk -F '\t' '{count[$1]++} END {for(i in count) {print count[i],"times      IP: " i}}' | grep -E "[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}"| sort -nrk 1 | head -n 100 >> ipTop100.txt 
    echo "Done! The result saved in ipTop100.txt"
}
# 统计最频繁被访问的URL TOP 100
function topUrl {
    cat web_log.tsv | awk -F '\t' '{count[$5]++} END {for(i in count) {print count[i],"times      URL: " i}}' | sort -nrk 1 | head -n 100 >> urlTop100.txt
    echo "Done! The result saved in urlTop100.txt"
}
# 统计不同响应状态码的出现次数和对应百分比
function statusCode {
    cat web_log.tsv | sed -e '1d' | awk -F '\t' '{count[$6]++;b++} END {for(i in count) {print "StatusCode: " i,"      Num: " count[i],"      Rate: " count[i]/b*100 "%"}}' | column -t >> statusCode.txt
    echo "Done! The result saved in statusCode.txt"
}
# 分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数
function 4xxStatusCode { 
    cat web_log.tsv |awk '{ if($6=="403") {count1[$5]++}} END { for(c in count1) {print count1[c],"times      StatusCode: 403,      URL:" c}}' |sort -nrk 1 | head -n 10 >> 403Code.txt
    cat web_log.tsv |awk '{ if($6=="404") {count2[$5]++}} END { for(c in count2) {print count2[c],"times      StatusCode: 404,      URL:" c}}' |sort -nrk 1 | head -n 10 >> 404Code.txt
	echo "Done! The results saved in 403Code.txt and 404Code.txt"
}
# 给定URL输出TOP 100访问来源主机
function topSH {
    cat web_log.tsv | awk -F '\t' '{if($5=="'$2'") {count[$1]++}} END {for(c in count) {print count[c],"times      URL: " c}}' "$1" |sort -nrk 1 |head -n 100 >> top100hostOfTheUrl.txt
    echo "Done! The result saved in top100hostOfTheUrl.txt"
}


# 主函数
if [ "$#" == 0 ]
then
    Operations
fi

while [ "$1" != "" ];do
    case "$1" in
        "-sh")
            topHost 
            shift ;;
        "-si")
            topIP 
            shift ;;
        "-ua")
            topUrl 
            shift ;;
        "-rc")
            statusCode 
            shift ;;
        "-ux")
            4xxStatusCode 
            shift ;;
        "-su")          
            topSH 
            shift ;;
        "-h" )
            Operations
            exit 0
    esac
done
