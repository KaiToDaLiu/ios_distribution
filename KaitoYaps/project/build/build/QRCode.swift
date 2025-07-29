//
//  QRCode.swift
//  build
//
//  Created by 大刘 on 2024/9/26.
//

import Foundation
import CoreImage
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

class QRCode {
    // Function to generate a QR code image from a string
    func generateQRCode(from string: String) -> CIImage? {
        // Convert the string to data
        // let data = string.data(using: .utf8)
        let data = string.data(using: .isoLatin1)
        // let data = data(using: .isoLatin1),
        let outputImage = CIFilter(name: "CIQRCodeGenerator",
                          parameters: ["inputMessage": data!, "inputCorrectionLevel": "L"])?.outputImage
        // Get the output image
                if let ciImage = outputImage {
                    // Scale up the CIImage to get a higher quality
                    // ciImage.transformed(by: <#T##CGAffineTransform#>, highQualityDownsample: <#T##Bool#>)
                    let scaledImage = ciImage.transformed(by: CGAffineTransform.init(scaleX: 5.0, y: 5.0))
                    return scaledImage
                }
        return outputImage
    }

    // Function to save CIImage to JPEG file
    @discardableResult
    func saveCIImageAsJPEG(ciImage: CIImage, to filePath: String, compressionQuality: CGFloat = 1.0) -> Bool {
        // Create a CIContext to convert CIImage to CGImage
        let context = CIContext(options: nil)
        
        // Create a CGImage from the CIImage
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            // Prepare for JPEG conversion using CGImageDestination
            let fileURL = URL(fileURLWithPath: filePath)
            // CGImageDestinationCreateWithURL(fileURL as CFURL, UTType.jpeg as! CFString, 1, nil)
            
            if let destination = CGImageDestinationCreateWithURL(fileURL as CFURL, UTType.jpeg.identifier as CFString, 1, nil) {
                // Add the CGImage to the destination with options for JPEG compression
                let options: [CFString: Any] = [kCGImageDestinationLossyCompressionQuality: compressionQuality]
                CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)
                
                // Finalize and save the image
                if CGImageDestinationFinalize(destination) {
                    print("Successfully saved JPEG to \(filePath)")
                    return true
                }
            }
        }
        print("Failed to save JPEG file.")
        return false
    }
    
    func saveQRImage(from string: String, path: String) {
        if let ciimage = generateQRCode(from: string) {
            saveCIImageAsJPEG(ciImage: ciimage, to: path)
        }
    }
}
