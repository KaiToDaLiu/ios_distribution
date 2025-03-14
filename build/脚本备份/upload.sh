export LANG=en_US.UTF-8

upload_gitpage() {
	project_dir=$(pwd)

	echo "----------------------------------"
	echo "👉 1. 新建文件夹"
	echo "----------------------------------"
	ios_distribution="/Users/daliu_kt/Desktop/job/GitHub/ios_distribution"
	ios_distribution_build="${ios_distribution}"/build
	CURRENT_TIME=$(date +"%Y_%m_%d_%H_%M_%S")
	MAC_TIME_DIR=${ios_distribution_build}/${CURRENT_TIME}
	mkdir $MAC_TIME_DIR
	echo $MAC_TIME_DIR

	echo "----------------------------------"
	echo "👉 2. 把要打包的东西移动到这个新建的文件夹内"
	echo "----------------------------------"
	#-- DistributionSummary.plist
	#-- ExportOptions.plist
	#-- KaiToApp.ipa
	#-- Packaging.log
	#-- dSYMs
	cp ./.build/output/* ${MAC_TIME_DIR}
	# cp ./* ${MAC_TIME_DIR} # TODO: - Change here!!!!!!
	echo "${project_dir} --> ${MAC_TIME_DIR}"

	echo "----------------------------------"
	echo "👉 3. copy manifest.plist 并修改"
	echo "----------------------------------"
	cp ${ios_distribution_build}/manifest_backup.plist ${MAC_TIME_DIR}/manifest.plist
	TARGET_URL="https://KaiToDaLiu.github.io/ios_distribution/build/${CURRENT_TIME}/KaiToApp.ipa" 
	/usr/libexec/PlistBuddy -c "Set items:0:assets:0:url ${TARGET_URL}" ${MAC_TIME_DIR}/manifest.plist
	echo ${MAC_TIME_DIR}/manifest.plist

	echo -e "----------------------------------"
	echo -e "👉 4. 生成二维码"
	echo -e "----------------------------------"
	cd ${MAC_TIME_DIR}
	# let manifestFullPath = "itms-services:///?action=download-manifest&url=" + gitPageHome + "build/" + ipaDirName + "/manifest.plist"
	GIT_PAGE_HOME="https://KaiToDaLiu.github.io/ios_distribution"
	MANIFEST_FULL_PATH="itms-services:///?action=download-manifest&url=${GIT_PAGE_HOME}/build/${CURRENT_TIME}/manifest.plist"
	/Users/daliu_kt/PycharmProjects/pythonProject/.venv/bin/python3 ${ios_distribution_build}/generate_qr.py ${MANIFEST_FULL_PATH} qrcode.jpg
	echo "manifest full path: ${MANIFEST_FULL_PATH}"
	echo "qr code path: ${MAC_TIME_DIR}/qrcode.jpg"

	echo "----------------------------------"
	echo "👉 5. 提交到 GitHub Pages"
	echo "----------------------------------"
    # 补：为了防止 git 库过大而 push 失败，把之前的先删除掉
    # 找到以 2025_ 开头的文件夹并删除
    # find "${ios_distribution}/build" -type d -name "2025_*" -print0 | xargs -0 rm -rf
    # 寻找以 2025_ 开头的前两个目录，并删除，如果符合条件的目录个数小于2，则不删除
    cd "${ios_distribution}/build"
    dirs=$(ls -d 2025_* 2>/dev/null | sort) # 列出所有以 2025_ 开头的目录，并将错误输出（如没有匹配项时的错误信息）重定向到 /dev/null 以避免显示，sort 对列出的目录进行正序排序
    count=$(echo "$dirs" | wc -l) # 计算匹配目录的数量
    if [ "$count" -ge 4 ]; then # 检查目录数量是否大于或等于 4
        echo "$dirs" | head -n 2 | xargs rm -r # 如果数量满足条件，按排序后的顺序删除前两个目录
        echo "删除以2025_开头的老目录：2个"
    else
        echo "目录个数小于4，不需要删除目录"
    fi
    
    cd ${ios_distribution}
    echo "提交代码 ${ios_distribution} --> ${GIT_PAGE_HOME}"
	pwd
	git add *
	git commit -m "add new build ${CURRENT_TIME}"
	git push

	echo "----------------------------------"
	echo "👉 6. Set build description"
	echo "----------------------------------"
	cd ${project_dir}
	pwd

    QR_URL_PATH="${GIT_PAGE_HOME}/build/${CURRENT_TIME}/qrcode.jpg"
    echo "DESC_INFO:${QR_URL_PATH},${MANIFEST_FULL_PATH}"
    
    # Regular expression: DESC_INFO:(.*),(.*)
    # Description: <img src ="\1" height="140" width="140" /><br/><a href="\2">Use camera scan and install</a>
}

upload_gitpage
