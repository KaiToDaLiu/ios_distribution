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
	# cp ./.build/output/* ${MAC_TIME_DIR}
	cp ./* ${MAC_TIME_DIR} # TODO: - Change here!!!!!!
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
	# echo DESC_INFO:${BASE_URL}/qrcode.png,${BASE_URL}/app-debug.apk
	# echo "DESC_INFO:${MAC_TIME_DIR}/qrcode.jpg,${MANIFEST_FULL_PATH}"
#    cp ${MAC_TIME_DIR}/qrcode.jpg ./qrcode.jpg # 否则 img src 不显示
#    echo "DESC_INFO:./qrcode.jpg,${MANIFEST_FULL_PATH}"
#    # echo "DESC_INFO:${project_dir}/qrcode.jpg,${MANIFEST_FULL_PATH}"
#	# <img src ="\1" height="140" width="140" ><a href='https://www.pgyer.com/xxxx'>Install Online</a>
#    # <img src ="\1" height="140" width="140" ><a href="\2">Install Online</a>
    
    QR_URL_PATH="${GIT_PAGE_HOME}/build/${CURRENT_TIME}/qrcode.jpg"
    echo "DESC_INFO:${QR_URL_PATH},${MANIFEST_FULL_PATH}"
}

upload_gitpage
