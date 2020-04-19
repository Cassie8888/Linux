#!bin/bash

# 支持命令行参数方式使用不同功能
function Operations {
	echo "Usage:	bash task1.sh [OPTION...]"
    echo "the options:"
	echo "-c	input width to adjust image size while retaining aspect ratio"
	echo "-d	use the required picture directory"
	echo "-h	get the help of the operations"
	echo "-j	use to specify the compression level of JPEG images"
	echo "-p	type the prefix you want to add to the image name"
	echo "-s	type the suffix you want to add to the image name"
	echo "-v	convert .png or .svg files to .jpg files"
	echo "-w	type the watermarking to be addWatermarkded in the picture"
}

# 对jpeg格式图片进行图片质量压缩
function compressJPG {                                                                                                                 
    [ -d "compressJPG_output" ] || mkdir "compressJPG_output"
	for p in "$1"*.jpg; do
	    fullname="$(basename "$p")"
		filename="${fullname%.*}"
        convert "$p" -quality "$2"% ./compressJPG_output/"$filename"."jpg"
	done
	echo "Compress JPEG Succeed!"
}

# 对jpeg/png/svg格式图片在保持原始宽高比的前提下压缩分辨率
function compressRP {
	[ -d "compressRP_output" ] || mkdir compressRP_output
	for p in $(find "$1" -regex  '.*\.jpg\|.*\.svg\|.*\.png'); do
		fullname="$(basename "$p")"
		filename="${fullname%.*}"
		extension="${fullname##*.}"
		convert "$p" -resize "$2" ./compressRP_output/"$filename"."$extension"
	done
	echo "Compress RP Succeed!"
}

# 对图片批量添加自定义文本水印
function addWatermark {
	[ -d "addWatermark_output" ] || mkdir addWatermark_output
	for p in $(find "$1" -regex  '.*\.jpg\|.*\.svg\|.*\.png'); do
		fullname="$(basename "$p")"
		filename="${fullname%.*}"
		extension="${fullname##*.}"
		width=$(identify -format %w "$p")
		convert  -gravity center -fill red \
		-size "${width}"x30 caption:"$2" "$p" +swap -gravity south \
		-composite ./addWatermark_output/"$filename"."$extension"
	done
	echo "Add Watermark Succeed!"
}

# 批量重命名（统一添加文件名前缀或后缀，不影响原始文件扩展名）
function addPrefix {
	[ -d "addPrefix_output" ] || mkdir addPrefix_output;
	for p in "$1"*.*; do
		fullname=$(basename "$p")		
		filename="${fullname%.*}"
		extension="${fullname##*.}"
		cp "$p" ./addPrefix_output/"$2""$filename"."$extension"
	done
	echo "Add Prefix Succeed!"
}
function addSuffix {
	[ -d "addSuffix_output" ] || mkdir addSuffix_output;
	for p in "$1"*.*; do
		fullname=$(basename "$p")
		filename="${fullname%.*}"
		extension="${fullname##*.}"
		cp "$p" ./addSuffix_output/"$filename""$2"."$extension"
	done
	echo "Add Suffix Succeed!"
}

# 将png/svg图片统一转换为jpg格式图片
function cvt2JPG {
	[ -d "cvt2JPG_output" ] || mkdir cvt2JPG_output
	for p in $(find "$1" -regex '.*\.svg\|.*\.png');do	
		fullname=$(basename "$p")
		filename="${fullname%.*}"
		extension="${fullname##*.}"
		convert "$p" ./cvt2JPG_output/"$filename"".jpg"
	done
	echo "Convert to JPEG Succeed!"
}

# 主函数
dir=""

if [[ "$#" -lt 1 ]]; then
	echo "Please input your commands."
else 
	while [[ "$#" -ne 0 ]]; do
		case "$1" in
		
			"-c")
				if [[ "$2" != '' ]]; then 
					compressRP "$dir" "$2"
					shift 2
				else 
					echo "try again!"
				fi
				;;
				
			"-d")
				dir="$2"
				shift 2
				;;
				
			"-j")
				if [[ "$2" != '' ]]; then 
					compressJPG "$dir" "$2"
					shift 2
				else 
					echo "try again!"
				fi
				;;
			"-h")
				Operations
				shift
				;;		
				
			"-p")
				if [[ "$2" != '' ]]; then 
					addPrefix "$dir" "$2"
					shift 2
				else 
					echo "try again!"
				fi
				;;
				
			"-s")
				if [[ "$2" != '' ]]; then 
					addSuffix "$dir" "$2"
					shift 2
				else 
					echo "try again!"
				fi
				;;
			
			"-v")
				cvt2JPG "$dir"
				shift
				;;
			"-w")
				if [[ "$2" != '' ]]; then 
					addWatermark "$dir" "$2"
					shift 2
				else 
					echo "try again!"
				fi
				;;
							
		esac
	done
fi