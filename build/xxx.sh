cd /Users/daliu_kt/Desktop/job/GitHub/ios_distribution/build
dirs=$(ls -d 2025_* 2>/dev/null)
count=$(echo "$dirs" | wc -l)
if [ "$count" -ge 2 ]; then
    echo "$dirs" | head -n 2 | xargs rm -r
    echo "删除以2025_开头的老目录：2个"
else
    echo "不需要删除目录"
fi
