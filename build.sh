#!/bin/bash

# .xcproject的名字，必填

workspace_name="./KaiToApp.xcworkspace"

# 指定项目的scheme名称（也就是工程的scheme名称），必填

scheme_name="KaiToApp"

# 指定要打包编译的方式 : Release,Debug。一般用Release。必填

build_configuration=Release

bundle_version=1.0.0

# MacOS 系统 SDK 版本

iphoneos_version="iphoneos17.5"

# method，打包的方式。方式分别为 app-store，ad-hoc，enterprise 和 development
# 下面四个参数只是在手动指定Pofile文件的时候用到，如果使用Xcode自动管理Profile,直接留空就好
# (跟method对应的)mobileprovision文件名，需要先双击安装.mobileprovision文件.手动管理Profile时必填
# 项目的bundleId，手动管理Profile时必填

method="app-store"
bundle_identifier="ai.kaito.KaiToApp"
    
#if [ ${build_configuration} == 'Release' ]; then
#	method="app-store"
#	bundle_identifier="ai.kaito.KaiToApp"
#	noti_bundle_identifier="com.pinganfu.xxx.youqian.XXXNotificationService"
#	mobileprovision_name="83acf85d-ccbf-46d8-bf02-3ceb530d55a1"
#	mobileprovision_extension_name="ab704eb1-d5d3-424e-879e-c32b7eed32ec"
#else
#	method="enterprise"
#	bundle_identifier="com.xxx.ent.yqb.stg5"
#	noti_bundle_identifier="com.xxx.ent.yqb.stg5.XXXNotificationService"
#	mobileprovision_name="aee4f998-2af0-4a49-8632-32c8a7fb8df6"
#	mobileprovision_extension_name="dcfceca1-6372-48b7-8d3b-7ebb57410faa"
#fi

echo "--------------------脚本配置参数检查--------------------"
sw_vers
echo "workspace_name = $workspace_name"
echo "scheme_name = $scheme_name"
echo "build_configuration = ${build_configuration}"
echo "bundle_identifier = $bundle_identifier"
echo "method = $method"
echo "mobileprovision_name = $mobileprovision_name "


# =======================脚本的一些固定参数定义(无特殊情况不用修改)======================

# 工程根目录

project_dir=`pwd`

# 指定输出导出文件夹路径

export_path="$project_dir/.build"

# 指定output路径

export_output_path="$export_path/output"

# 指定输出归档文件路径

export_archive_path="$export_path/$scheme_name.xcarchive"

# 指定输出ipa文件夹路径

export_ipa_path="$export_output_path/$target_name.ipa"

# 指定导出ipa包需要用到的plist配置文件的路径

export_options_plist_path="$export_path/ExportOptions.plist"

echo "创建打包过程输出文件output目录 "$export_output_path
mkdir -p $export_output_path
echo "开始前：ls -alth $export_output_path:"
ls -alth $export_output_path

echo "--------------------脚本固定参数检查--------------------"
echo "project_dir = "$project_dir
echo "export_path = "$export_path
echo "export_archive_path = "$export_archive_path
echo "export_ipa_path = "$export_ipa_path
echo "export_options_plist_path = "$export_options_plist_path

# echo "user_config_archive_path = "$user_config_archive_path

# =======================自动打包部分(无特殊情况不用修改)======================

echo "------------------------------------------------------"
echo "开始构建项目 "

# 进入项目工程目录

cd $project_dir

# 指定输出文件目录不存在则创建

if [ -d "$export_path" ];
then rm -rf "$export_path"
fi

# 编译前清理工程

xcodebuild clean -workspace $workspace_name \
-scheme "$scheme_name" \
-configuration ${build_configuration}

echo "============== 开始读取动态配置 =================="

if [ ${build_configuration} == 'Release' ]; then
	envName='PRD'
	PackingCertificate='ReleaseCertificate'
	displayName='Kaito'
else
	envName='TestStable'
	PackingCertificate='InHouseCertificate'
	displayName="Kaito${ENV}"
fi

echo "============== 修改Podfile =================="

echo "============== 修改info.plist =================="
now=`date +%y%m%d%H%M`
bundle_short_version=${bundle_version}.$now
# main app
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName ${displayName}" $project_dir/Supporting/PAQZZ-Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${bundle_version}" $project_dir/Supporting/KaiToApp-Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $bundle_short_version" $project_dir/Supporting/PAQZZ-Info.plist
# extension
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${bundle_version}" $project_dir/YQBNotificationService/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $bundle_short_version" $project_dir/YQBNotificationService/Info.plist

# #安装依赖
#sh podinstalldev.sh
sh pod install

# # 开始编译

xcodebuild archive -workspace $workspace_name \
-scheme "$scheme_name" \
-configuration ${build_configuration} \
-sdk $iphoneos_version \
-archivePath "$export_archive_path" \
-quiet


# 检查是否构建成功

# xcarchive 实际是一个文件夹不是一个文件所以使用 -d 判断

if [ -d "$export_archive_path" ] ; then
echo "项目构建成功 🚀 🚀 🚀 "
else
echo "项目构建失败 😢 😢 😢 "
exit 1
fi
echo "------------------------------------------------------"

echo "开始导出ipa文件 "

# # 先删除export_options_plist文件

if [ -f "$export_options_plist_path" ] ; then
echo "$export_options_plist_path文件存在，进行删除"
rm -f $export_options_plist_path
fi

echo "用户选择采用系统自动生成方式产生pList文件，系统将根据参数生成export_options_plist文件"

# 根据参数生成export_options_plist文件

/usr/libexec/PlistBuddy -c "Add :compileBitcode bool NO" $export_options_plist_path
/usr/libexec/PlistBuddy -c "Add :method String $method" $export_options_plist_path
/usr/libexec/PlistBuddy -c "Add :provisioningProfiles:$bundle_identifier String $mobileprovision_name" $export_options_plist_path
/usr/libexec/PlistBuddy -c "Add :provisioningProfiles:$noti_bundle_identifier String $mobileprovision_extension_name" $export_options_plist_path
/usr/libexec/PlistBuddy -c "Add :signingCertificate String iPhone Distribution" $export_options_plist_path
/usr/libexec/PlistBuddy -c "Add :signingStyle String manual" $export_options_plist_path
if [ ${build_configuration} == 'Release' ]; then
	/usr/libexec/PlistBuddy -c "Add :teamID String SQ6RYBYJ9D" $export_options_plist_path
else
	/usr/libexec/PlistBuddy -c "Add :teamID String N62QCG5ZVN" $export_options_plist_path
fi
echo "开始打印 ExportOptions.plist 文件："
cat $export_options_plist_path
/usr/libexec/PlistBuddy -c "print" $export_options_plist_path

#输出ipa
xcodebuild -exportArchive \
-archivePath "$export_archive_path" \
-exportPath "$export_ipa_path" \
-exportOptionsPlist $export_options_plist_path

# 删除export_options_plist文件（中间文件）

if [ -f "$export_options_plist_path" ] ; then
echo "$export_options_plist_path 文件存在，准备删除"
rm -f $export_options_plist_path
fi

echo "============== 动态参数日志 =================="
echo " 代码分支:${scm_branch} \n commitID:${scm_revision_0} \n App版本:${bundle_version} \n 证书:${PackingCertificate} \n 模式:${build_configuration} \n Kaito环境:${ENV}"

# 输出打包总用时

mv -f .build/output/.ipa/Kaito.ipa .build/output/.ipa/Kaito-${scm_branch}-${envName}-${bundle_short_version}.ipa

# 导出dsym(.build目录在任务完成时会被清除，所以需要cp)

mkdir -p output
zip -r -q output/xcarchive.zip .build/"$scheme_name".xcarchive
cp -f .build/output/.ipa/*.ipa output/

echo "本次打包用时: $SECONDS s"
exit 0
