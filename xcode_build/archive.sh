#!/bin/bash

# 配置参数
workspace_name="./KaiToApp.xcworkspace"
scheme_name="KaiToApp"
build_configuration="Release"   # 可以通过传参来动态指定
bundle_version="1.0.0"
iphoneos_version="iphoneos"
project_dir=$(pwd)
export_path="$project_dir/.build"
export_output_path="$export_path/output"
export_archive_path="$export_path/$scheme_name.xcarchive"
export_ipa_path="$export_output_path/Kaito-${bundle_short_version}.ipa"
export_options_plist_path="$export_path/ExportOptions.plist"
export_dsym_path="$export_output_path/dSYMs"  # 新增 dSYM 输出路径

# 记录构建日期
touch "$project_dir/work/build/build_date.txt"

# 创建输出目录
mkdir -p "$export_output_path"
mkdir -p "$export_dsym_path"  # 创建 dSYM 目录

# 根据环境设置参数
set_build_config() {
    if [[ "$1" == 'Release' ]]; then
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
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $bundle_short_version" "$info_plist_path"
    echo "版本号更新为: $bundle_short_version"
}


# 安装依赖
install_dependencies() {
    echo "------------------------------------------------------"
    echo "安装CocoaPods依赖..."
    pod install
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

# 开始执行
clean_project
update_plist_version
install_dependencies
build_project
generate_export_plist
export_ipa
export_dsyms  # 调用导出 dSYM
cleanup
exit 0

