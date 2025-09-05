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

    let info = Info()
    info.parse()
    
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
                info.logArchiveInformation()
            } else if input.lowercased() == "2" {
                shouldExit = false
                info.logHTML()
            } else if input.lowercased() == "q" {
                shouldExit = true
                print("Bye")
            }
        }
    }

    print("Exiting program...")
}

runUntilQuit()
