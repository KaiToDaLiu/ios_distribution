CURRENT_TIME=$(date +"%Y_%m_%d_%H_%M_%S")
TARGET_STR="https://KaiToDaLiu.github.io/ios_distribution/build/${CURRENT_TIME}/KaiToApp.ipa"
/usr/libexec/PlistBuddy -c "Set items:0:assets:0:url ${TARGET_STR}" manifest_backup_2.plist
