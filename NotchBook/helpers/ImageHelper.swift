//
//  ImageHelper.swift
//  NotchBook
//
//  Created by Guruprasad Meena on 14/10/24.
//

import AppKit

struct ImageHelper {
    static func calculateAverageColor(from albumArtwork: NSImage?) -> NSColor? {
        guard let albumArtwork = albumArtwork,
              let cgImage = albumArtwork.cgImage(forProposedRect: nil, context: nil, hints: nil),
              let dataProvider = cgImage.dataProvider,
              let pixelData = dataProvider.data else { return nil }
        
        let data = CFDataGetBytePtr(pixelData)
        let width = cgImage.width
        let height = cgImage.height
        
        var totalRed = 0, totalGreen = 0, totalBlue = 0
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = ((width * y) + x) * 4
                totalRed += Int(data?[pixelIndex] ?? 0)
                totalGreen += Int(data?[pixelIndex + 1] ?? 0)
                totalBlue += Int(data?[pixelIndex + 2] ?? 0)
            }
        }
        
        let pixelCount = width * height
        let avgRed = totalRed / pixelCount
        let avgGreen = totalGreen / pixelCount
        let avgBlue = totalBlue / pixelCount
        
        return NSColor(red: CGFloat(avgRed) / 255.0, green: CGFloat(avgGreen) / 255.0, blue: CGFloat(avgBlue) / 255.0, alpha: 1.0)
    }
}
