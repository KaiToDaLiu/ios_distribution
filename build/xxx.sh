cd /Users/daliu_kt/Desktop/job/GitHub/ios_distribution/build
dirs=$(ls -d 2025_* 2>/dev/null | sort) # 列出所有以 2025_ 开头的目录，并将错误输出（如没有匹配项时的错误信息）重定向到 /dev/null 以避免显示，sort 对列出的目录进行正序排序
count=$(echo "$dirs" | wc -l) # 计算匹配目录的数量
if [ "$count" -ge 4 ]; then # 检查目录数量是否大于或等于 4
    echo "$dirs" | head -n 2 | xargs rm -r # 如果数量满足条件，按排序后的顺序删除前两个目录
    echo "删除以2025_开头的老目录：2个"
else
    echo "目录个数小于4，不需要删除目录"
fi