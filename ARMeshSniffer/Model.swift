//
//  Model.swift
//  ARMeshSniffer
//
//  Created by Ethan on 12/12/2020.
//

import Foundation
import UIKit


struct SniffBlock: Codable {
    var vertices: [SIMD3<Float>]
    var image: RawImage
    var camInfo: CameraInfo
}

struct RawImage: Codable {
    var jpegData: Data

    public init(_ pixelBuffer: CVPixelBuffer) {
        let image = UIImage(ciImage: CIImage(cvPixelBuffer: pixelBuffer))
        if let data = image.jpegData(compressionQuality: 0.85) {
            self.jpegData = data
        } else {
            print("WARNING: Empty frame")
            jpegData = Data()
        }
    }
}
//Deserialize:
//UIImage(data: instanceOfSomeImage.photo)!

struct CameraInfo: Codable {
    var imageWidth: Float
    var imageHeight: Float
    var exposureDuration: Double
}
