//
//  UIImage+Extensions.swift
//  AllGoalsFramework
//
//  Created by Ruben Roques on 12/11/2019.
//  Copyright © 2019 GOMA Development. All rights reserved.
//

import Foundation
import UIKit

// swiftlint:disable all

extension UIImage {

    @available(iOS 12.0, *)
    func getPixels() -> [UIColor] {
        guard let cgImage = self.cgImage else {
            return []
        }
        assert(cgImage.bitsPerPixel == 32, "only support 32 bit images")
        assert(cgImage.bitsPerComponent == 8,  "only support 8 bit per channel")
        guard let imageData = cgImage.dataProvider?.data as Data? else {
            return []
        }
        let size = cgImage.width * cgImage.height
        let buffer = UnsafeMutableBufferPointer<UInt32>.allocate(capacity: size)
        _ = imageData.copyBytes(to: buffer)
        var result = [UIColor]()
        result.reserveCapacity(size)
        for pixel in buffer {
            var r : UInt32 = 0
            var g : UInt32 = 0
            var b : UInt32 = 0
            if cgImage.byteOrderInfo == .orderDefault || cgImage.byteOrderInfo == .order32Big {
                r = pixel & 255
                g = (pixel >> 8) & 255
                b = (pixel >> 16) & 255
            } else if cgImage.byteOrderInfo == .order32Little {
                r = (pixel >> 16) & 255
                g = (pixel >> 8) & 255
                b = pixel & 255
            }
            let color = UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1)
            result.append(color)
        }
        return result
    }

    func getPixelColor(pos: CGPoint) -> UIColor? {

        if
            let dataProvider = self.cgImage?.dataProvider,
            let data = dataProvider.data,
            let pointer = CFDataGetBytePtr(data)
        {
            let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4

            let red: CGFloat = CGFloat(pointer[pixelInfo]) / CGFloat(255)
            let green: CGFloat = CGFloat(pointer[pixelInfo+1]) / CGFloat(255)
            let blue: CGFloat = CGFloat(pointer[pixelInfo+2]) / CGFloat(255)
            let alpha: CGFloat = CGFloat(pointer[pixelInfo+3]) / CGFloat(255)

            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
        return nil
    }

    func getGradientColorImage(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat, bounds:CGRect) -> UIImage
    {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(red: (red / 255.0), green: (green / 255.0), blue: (blue / 255.0), alpha: alpha).cgColor, UIColor(red: (red / 255.0), green: (green / 255.0), blue: (blue / 255.0), alpha: alpha).cgColor]
        gradientLayer.bounds = bounds
        UIGraphicsBeginImageContextWithOptions(gradientLayer.bounds.size, true, 0.0)
        let context = UIGraphicsGetCurrentContext()
        gradientLayer.render(in: context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}




extension UIImage {
    func pixelColor(x: Int, y: Int) -> UIColor? {
        guard x >= 0 && x < Int(size.width) && y >= 0 && y < Int(size.height),
              let cgImage = cgImage,
              let provider = cgImage.dataProvider,
              let providerData = provider.data,
              let data = CFDataGetBytePtr(providerData) else {
            return nil
        }

        let numberOfComponents = 4
        let pixelData = ((Int(size.width) * y) + x) * numberOfComponents

        let r = CGFloat(data[pixelData]) / 255.0
        let g = CGFloat(data[pixelData + 1]) / 255.0
        let b = CGFloat(data[pixelData + 2]) / 255.0
        let a = CGFloat(data[pixelData + 3]) / 255.0

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }


    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }

}


// swiftlint:enable all
