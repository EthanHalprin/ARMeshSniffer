//
//  ViewModel.swift
//  ARMeshSniffer
//
//  Created by Ethan on 09/12/2020.
//

import Foundation
import UIKit

class ViewModel {
    
    var filename = "armesh_results.bin"
    let fileURL = URL(fileURLWithPath: "armesh_results.bin")
    let documentInteractionController = UIDocumentInteractionController()
    
    /// Saves data as pdf in the Files app system on the device
    ///
    /// - Parameters:
    ///
    ///   - documentData: data to persist in file
    ///   - vc: ViewController to open modal on
    ///
    /// - Note:
    ///
    ///   You can't force it to be downloaded and show up in their Files app.
    ///   You have to present a UIActivityViewController that shows options on
    ///   what they can do with that document.
    func savePDF(_ documentData: Data, presenter vc: UIViewController) {
        let activityController = UIActivityViewController(activityItems: [documentData], applicationActivities: nil)
        vc.present(activityController, animated: true, completion: nil)
    }
    
    let url = URL(fileURLWithPath: "myTestFile.bin")

    func write(_ wArray: inout [Float]) {
        // Writing
        let wData = Data(bytes: &wArray, count: wArray.count * MemoryLayout<Float>.stride)
        
        if let dir = FileManager.default.urls(for: .documentDirectory,
                                              in: .userDomainMask).first {
            let url = dir.appendingPathComponent(self.filename)
            do {
                try wData.write(to: url)
            }
            catch {
                print("ERROR: Could not write to binary file")
            }
        }
    }
 

    func read() -> [Float]? {
        
        var rData: Data?
        
        if let dir = FileManager.default.urls(for: .documentDirectory,
                                              in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(self.filename)
            do {
                rData = try Data(contentsOf: fileURL)
            }
            catch {
                print("ERROR: Could not read from binary file")
            }
        }

        if let data = rData {
            var rArray: [Float]?

            data.withUnsafeBytes { (bytes: UnsafePointer<Float>) in
                rArray = Array(UnsafeBufferPointer(start: bytes, count: data.count / MemoryLayout<Float>.size))
            }

            return rArray!
        } else {
            return nil
        }
    }
}
