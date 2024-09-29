//
//  main.swift
//  build
//
//  Created by 大刘 on 2024/9/26.
//

import Foundation
import CoreImage

func runUntilQuit() {
    print("Program started. Type 'q' to quit.")
    var shouldExit = false

    // Keep the program running in a loop
    while !shouldExit {
        // Prompt for user input
        let hintStr = """
1. get information
2. generate qr code
q. quit\n
Input Numbers:
"""
        print(hintStr, terminator: "")
        
        // Capture input from the user
        if let input = readLine() {
            if input.lowercased() == "1" {
                shouldExit = false
                let build = Build()
                if var date = build.getBuildDate() {
                    date = date.trimmingCharacters(in: .whitespacesAndNewlines)
                    let gitPath = "https://KaiToDaLiu.github.io/ios_distribution/"
                    print("=============================================")
                    print(date) // 2024_09_26_14_56_09
                    print("https://KaiToDaLiu.github.io/ios_distribution/build/" + date + "/KaiToApp.ipa")
                    print("https://KaiToDaLiu.github.io/ios_distribution/57.png")
                    print("https://KaiToDaLiu.github.io/ios_distribution/512.png")
                    print("\n")
                    print("=============================================")
                }
            } else if input.lowercased() == "2" {
                let currentPath = FileManager.default.currentDirectoryPath
                print("Current path: \(currentPath)")
                return
                
                shouldExit = false
                let build = Build()
                if var date = build.getBuildDate() {
                    date = date.trimmingCharacters(in: .whitespacesAndNewlines)
                    let manifestName = date + "/" + "manifest.plist"
                    let manifestFullPath = "itms-services:///?action=download-manifest&url=https://KaiToDaLiu.github.io/ios_distribution/build/" + manifestName
                    print("=============================================")
                    print(manifestFullPath)
                    let destPath = "/Users/daliu_kt/Desktop/job/GitHub/ios_distribution/build/" + date + "/qrcode.jpg"
                    QRCode().saveQRImage(from: manifestFullPath, path: destPath)
                    print("insert div:")
                    let div = """
<div class="vertical">
                <img src="build/\(date)/qrcode.jpg" alt="scan it with iphone camera">
                \(Build.splitDate(date))
            </div>
"""
                    print(div)
                    print("=============================================")
                }
            } else if input.lowercased() == "q" {
                shouldExit = true
                print("Bye")
            }
        }
    }

    print("Exiting program...")
}

runUntilQuit()
