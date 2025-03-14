#!/bin/bash

# https://blog.csdn.net/LIUXIAOXIAOBO/article/details/127038257
# CocoaPods requires your terminal to be using UTF-8 encoding.
# Consider adding the following to ~/.profile:
# export LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# 配置参数
workspace_name="./KaiToApp.xcworkspace"
scheme_name="KaiToApp"
build_configuration=$BUILD_CONFIGURATION #"Release"   # 可以通过传参来动态指定 🫵 可配置
bundle_version="1.0.0"
iphoneos_version="iphoneos"
project_dir=$(pwd)
export_path="$project_dir/.build"
export_output_path="$export_path/output" # 导出路径：当前目录/output/
export_archive_path="$export_path/$scheme_name.xcarchive"
export_ipa_path="$export_output_path/Kaito-${bundle_short_version}.ipa" # 导出 ipa 路径
export_options_plist_path="$export_path/ExportOptions.plist"
export_dsym_path="$export_output_path/dSYMs"  # 新增 dSYM 输出路径

echo "$project_dir" # /Users/daliu_kt/Desktop/job/GitHub/KaiToApp

# 记录构建日期
# touch "$project_dir/work/build/build_date.txt"

# 创建输出目录
mkdir -p "$export_output_path" # /Users/daliu_kt/Desktop/job/GitHub/KaiToApp/.build/output
mkdir -p "$export_dsym_path"  # /Users/daliu_kt/Desktop/job/GitHub/KaiToApp/.build/output/dSYMs

# 根据环境设置参数
set_build_config() {
    if [[ "$1" == 'Release' ]]; then # Current: Release
        method="ad-hoc"
        bundle_identifier="ai.kaito.kaito"
        mobileprovision_name="ai.kaito.kaito.adhoc_profile_name"  # 替换为实际配置文件名称
        team_id="358UF6MCG5"
    else
        method="enterprise"
        bundle_identifier="ai.kaito.kaito"
        mobileprovision_name="ai.kaito.kaito.adhoc_profile_name"      # 替换为实际配置文件名称
        team_id="Z5T3LF59XR"
    fi
}

# 根据参数设置build_configuration
set_build_config "$build_configuration"

echo "-------------------- 环境配置检查 --------------------"
echo "Workspace: $workspace_name"
echo "Scheme: $scheme_name"
echo "Build Config: $build_configuration"
echo "Bundle ID: $bundle_identifier"
echo "Method: $method"
echo "Team ID: $team_id"
echo "工程目录：$project_dir"
echo "工程名：$workspace_name"
echo "版本号：$bundle_version"
echo "打包路径：$export_output_path"
echo "dsym路径：$export_dsym_path"

# 清理项目
clean_project() {
    echo "------------------------------------------------------"
    echo "清理工程..."
    xcodebuild clean -workspace "$workspace_name" \
                     -scheme "$scheme_name" \
                     -configuration "$build_configuration"
}

# 修改Info.plist版本号
#update_plist_version() {
#    info_plist_path="$project_dir/$scheme_name/Supporting/KaiToApp-Info.plist"
#    if [[ ! -f "$info_plist_path" ]]; then
#        echo "错误：Info.plist 文件不存在！"
#        exit 1
#    fi
#
#    now=$(date +%y%m%d%H%M)
#    bundle_short_version="${bundle_version}.$now"
#    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $bundle_short_version" "$info_plist_path"
#    echo "版本号更新为: $bundle_short_version"
#}
#///0304
#update_plist_version() {
#    # 修正后的正确路径
#    info_plist_path="$project_dir/$scheme_name/Info.plist"
#    
#    if [[ ! -f "$info_plist_path" ]]; then
#        echo "错误：Info.plist 文件不存在！路径：$info_plist_path"
#        exit 1
#    fi
#
#    now=$(date +%y%m%d%H%M)
#    bundle_short_version="${bundle_version}.$now"
#    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $bundle_short_version" "$info_plist_path"
#    echo "版本号更新为: $bundle_short_version"
#}

update_plist_version() {
    # 自动查找 Info.plist
    info_plist_path=$(find "$project_dir" -name "Info.plist" | head -n 1)

    if [[ ! -f "$info_plist_path" ]]; then
        echo "错误：Info.plist 文件不存在！"
        exit 1
    fi

    now=$(date +%y%m%d%H%M)
    bundle_short_version="${bundle_version}.$now"
    # PlistBuddy
    # https://medium.com/@marksiu/what-is-plistbuddy-76cb4f0c262d
    # https://stackoverflow.com/questions/24226173/plistbuddy-or-code-to-display-version-information-ios
    # 遇到了一个问题：说是 Set :CFBundleVersion 不存在，解决方法：在Info.plist中添加 Bundle Version: $(CURRENT_PROJECT_VERSION)
    #  https://stackoverflow.com/questions/19164939/modifying-info-plists-cfbundleversion-in-xcode-5-with-asset-library-enabled
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $bundle_short_version" "$info_plist_path"
    echo "版本号更新为: $bundle_short_version"
}

# 安装依赖
install_dependencies() {
    # 遇到的问题：
    # error: jenkins上pod命令不存在
    # https://stackoverflow.com/questions/25518916/cant-run-pod-install-in-jenkins
    # /usr/local/bin/pod install
    
    # export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890
    # pod repo remove master
    # pod repo add master https://ruby.taobao.org/

    # 遇到的问题：
    # error: Unable to open base configuration reference file '/Users/daliu_kt/.jenkins/workspace/iOSKaitoApp/Pods/Target Support Files/Pods-KaiToApp/Pods-KaiToApp.release.xcconfig'. (in target 'KaiToApp' from project 'KaiToApp')
    echo "------------------------------------------------------"
    echo "安装CocoaPods依赖..."
    /usr/local/bin/pod cache clean --all
    # pod update
    /usr/local/bin/pod install
}

# 编译项目
build_project() {
    echo "------------------------------------------------------"
    echo "开始构建项目..."
    xcodebuild archive -workspace "$workspace_name" \
                       -scheme "$scheme_name" \
                       -configuration "$build_configuration" \
                       -sdk "$iphoneos_version" \
                       -archivePath "$export_archive_path" \
                       -EXCLUDED_ARCHS="arm64"
                       CODE_SIGN_STYLE="Manual" \
                       PROVISIONING_PROFILE_SPECIFIER="$mobileprovision_name" \
                       DEVELOPMENT_TEAM="$team_id" \
                       -quiet
    if [[ ! -d "$export_archive_path" ]]; then
        echo "错误：项目构建失败！"
        exit 1
    fi
    echo "项目构建成功 ✅"
}

# 生成ExportOptions.plist
generate_export_plist() {
    echo "------------------------------------------------------"
    echo "生成ExportOptions.plist..."
    cat > "$export_options_plist_path" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>compileBitcode</key>
    <false/>
    <key>method</key>
    <string>$method</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>$bundle_identifier</key>
        <string>$mobileprovision_name</string>
    </dict>
    <key>signingCertificate</key>
    <string>iPhone Distribution: Kaito Pte. Ltd.</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>teamID</key>
    <string>$team_id</string>
</dict>
</plist>
EOF
    echo "ExportOptions.plist内容："
    cat "$export_options_plist_path"
}

# 导出IPA
export_ipa() {
    echo "------------------------------------------------------"
    echo "导出IPA文件..."
    xcodebuild -exportArchive \
               -archivePath "$export_archive_path" \
               -exportPath "$export_output_path" \
               -exportOptionsPlist "$export_options_plist_path"

    if [[ $? -ne 0 ]]; then
        echo "错误：IPA导出失败！"
        exit 1
    fi
    echo "IPA导出成功 ✅"
    echo "输出路径: $export_output_path"
}

# 清理临时文件
cleanup() {
    rm -f "$export_options_plist_path"
    echo "------------------------------------------------------"
    echo "打包完成! 总耗时: ${SECONDS}s"
}

# 导出 dSYM 文件
#export_dsyms() {
#    echo "------------------------------------------------------"
#    echo "导出 dSYM 文件..."
#    dsym_source_path="$export_archive_path/dSYMs"
#    if [[ -d "$dsym_source_path" ]]; then
#        cp -R "$dsym_source_path/" "$export_dsym_path"
#        echo "dSYM 文件已导出到: $export_dsym_path"
#        zip -r "$export_dsym_path/dSYMs.zip" "$export_dsym_path" >/dev/null
#        echo "dSYM 文件已压缩为: $export_dsym_path/dSYMs.zip"
#    else
#        echo "警告：未找到 dSYM 文件！"
#    fi
#}

#/// 0304
#export_dsyms() {
#    echo "------------------------------------------------------"
#    echo "导出主项目的 dSYM 文件..."
#    dsym_source_path="$export_archive_path/dSYMs"
#    
#    if [[ -d "$dsym_source_path" ]]; then
#        # 查找主项目的 dSYM 文件（通常以 .app.dSYM 结尾）
#        main_dsym=$(find "$dsym_source_path" -name "*.app.dSYM" -maxdepth 1)
#
#        if [[ -n "$main_dsym" ]]; then
#            mkdir -p "$export_dsym_path"
#            cp -R "$main_dsym" "$export_dsym_path/"
#            echo "主项目 dSYM 文件已导出到: $export_dsym_path"
#            zip -r "$export_dsym_path/dSYMs.zip" "$export_dsym_path" >/dev/null
#            echo "dSYM 文件已压缩为: $export_dsym_path/dSYMs.zip"
#        else
#            echo "警告：未找到主项目的 dSYM 文件！"
#        fi
#    else
#        echo "警告：未找到 dSYM 目录！"
#    fi
#}

#/// 添加上传firebase功能
export_dsyms() {
    echo "------------------------------------------------------"
    echo "导出主项目的 dSYM 文件..."

    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    dsym_source_path="$export_archive_path/dSYMs"
    export_dsym_path="$script_dir/.build/output/dSYMs"

    if [[ -d "$dsym_source_path" ]]; then
        # 查找主项目的 dSYM 文件（通常以 .app.dSYM 结尾）
        main_dsym=$(find "$dsym_source_path" -name "*.app.dSYM" -maxdepth 1)

        if [[ -n "$main_dsym" ]]; then
            mkdir -p "$export_dsym_path"
            cp -R "$main_dsym" "$export_dsym_path/"
            echo "主项目 dSYM 文件已导出到: $export_dsym_path"

            zip_file="$export_dsym_path/dSYMs.zip"
            zip -r "$zip_file" "$export_dsym_path" >/dev/null
            echo "dSYM 文件已压缩为: $zip_file"

            # 使用相对路径
            upload_symbols_path="$script_dir/Pods/FirebaseCrashlytics/upload-symbols"
            google_service_plist="$script_dir/KaiToApp/GoogleService-Info.plist"

#            echo "开始上传 dSYM 文件到 Firebase Crashlytics..."
#            "$upload_symbols_path" -gsp "$google_service_plist" -p ios "$export_dsym_path"
#            if [[ $? -eq 0 ]]; then
#                echo "✅ dSYM 文件上传成功！"
#            else
#                echo "❌ dSYM 文件上传失败！请检查日志。"
#            fi
        else
            echo "⚠️ 警告：未找到主项目的 dSYM 文件！"
        fi
    else
        echo "⚠️ 警告：未找到 dSYM 目录！"
    fi
}

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

# 开始执行
clean_project
# update_plist_version # 更新plist版本号
install_dependencies   # 安装依赖
build_project   	   # 编译工程，生成 KaiToApp.xcarchive
generate_export_plist  # 生成ExportOptions.plist
export_ipa             # 导出 ipa 包
export_dsyms  		   # 导出符号表 dSYM
#cleanup
upload_gitpage         # 上传到 gitPage, 生成二维码

exit 0
