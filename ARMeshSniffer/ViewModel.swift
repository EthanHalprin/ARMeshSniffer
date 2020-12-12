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
        let activityController = UIActivityViewController(activityItems: [documentData],
                                                          applicationActivities: nil)
        vc.present(activityController, animated: true, completion: nil)
    }
    
    func write(_ block: SniffBlock) {
        
        var blockData: Data?
        
        do {
            blockData = try JSONEncoder().encode(block)
        } catch {
            fatalError("ERROR: Cannot decode SniffBlock")
        }
        
        if let dir = FileManager.default.urls(for: .documentDirectory,
                                              in: .userDomainMask).first {
            let url = dir.appendingPathComponent(self.filename)
            if let blockData = blockData {
                do {
                    try blockData.write(to: url)
                }
                catch {
                    print("ERROR: Could not write to binary file")
                }
            }
        }
    }
    
    func read() -> SniffBlock? {
    
        var data: Data?
        var sniffedBlock: SniffBlock?
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(self.filename)
            do {
                data = try Data(contentsOf: fileURL)
            }
            catch {
                print("ERROR: Could not encode SniffBlock to data")
            }
        }
        
        if let data = data {
            do {
                sniffedBlock = try JSONDecoder().decode(SniffBlock.self, from: data)
            } catch {
                print("ERROR: Could not decode SniffBlock from data")
            }
        }
        
        return sniffedBlock
    }
    
    func write(_ wArray: inout [Float]) {
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
    func readBin() -> [Float]? {
    
        var rData: Data?
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(self.filename)
            do {
                rData = try Data(contentsOf: fileURL)
            }
            catch {
                print("ERROR: Could not read from binary file")
            }
        }
        var rArray: [Float]?
        if let rData = rData {

            let tPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: rData.count)
            rData.copyBytes(to: tPointer, count: rData.count)

            defer {
                tPointer.deinitialize(count: rData.count)
                tPointer.deallocate()
            }

            let pointer = UnsafeRawPointer(tPointer) // Performs no allocation or copying; no deallocation shall be done.
            rArray = [Float]()
            var offset = 00
            let count = 3
            for _ in 0..<count {
                rArray!.append(pointer.load(fromByteOffset: offset, as: Float.self))
                offset += MemoryLayout<Float>.size
            }
        }
        return rArray
    }
}
