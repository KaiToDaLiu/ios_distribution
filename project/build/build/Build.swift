//
//  Build.swift
//  build
//
//  Created by 大刘 on 2024/9/26.
//

import Foundation

class Build {
    let build_date_path = "/Users/daliu_kt/Desktop/job/GitHub/KaiToApp/build/build_date.txt"
    let distribution_path = "/Users/daliu_kt/Desktop/job/GitHub/ios_distribution/build/"
    var buildDate: String?
    
    func getBuildDate() -> String? {
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: build_date_path) {
            do {
                let fileContents = try String(contentsOfFile: build_date_path, encoding: .utf8)
                self.buildDate = fileContents
                return fileContents
            } catch {
                print("Error reading file: \(error)")
                return nil
            }
        } else {
            print("File does not exist")
            return nil
        }
    }
    
    static func splitDate(_ str: String) -> String {
        // 2024_09_26_14_56_09
        let arr = str.components(separatedBy: "_")
        if arr.count == 6 {
            return arr[0] + "-" + arr[1] + "-" + arr[2] + " " + arr[3] + ":" + arr[4] + ":" + arr[5]
        }
        return ""
    }
}
