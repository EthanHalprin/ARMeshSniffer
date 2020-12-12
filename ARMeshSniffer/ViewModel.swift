//
//  ViewModel.swift
//  ARMeshSniffer
//
//  Created by Ethan on 09/12/2020.
//
import Foundation
import UIKit
import ARKit

class ViewModel {
    
    var filename = "armesh_results.bin"
    var url: URL?
    var contentNode: SCNNode?
    var framesCount = 0
    var operationQueue = OperationQueue()

    
    init() {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            self.url = dir.appendingPathComponent(self.filename)
        }
    }

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
    
    func writeToFile(_ block: SniffBlock) {
        
        guard let fileURL = self.url else {
            return
        }
        
        var blockData: Data?
        
        do {
            blockData = try JSONEncoder().encode(block)
        } catch {
            fatalError("ERROR: Cannot decode SniffBlock")
        }
        
        do {
            try blockData?.write(to: fileURL)
        } catch {
            print("ERROR: Could not write to binary file")
        }
    }
    
    func readFromFile() -> SniffBlock? {
    
        var data: Data?
        var sniffedBlock: SniffBlock?
        
        guard let fileURL = self.url else {
            return nil
        }

        do {
            data = try Data(contentsOf: fileURL)
        }
        catch {
            print("ERROR: Could not encode SniffBlock to data")
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
   
    func displaySavedFileContent() {
        
        for i in 0..<framesCount {
            
            if let sniffedBlock = readFromFile() {
                
                guard let vertices = sniffedBlock.vertices else { break }
                
                print("\n\n======== FRAME #\(i)  ====================================================")

                print("\n\n \(vertices.count) VERTICES :         \n\n ")
                print("\(String(describing: vertices))")

                if let img = sniffedBlock.image {
                    print("\n\n IMAGE          \n\n ")
                    print("\(String(describing: img))")
                }

                if let cam = sniffedBlock.camInfo {
                    print("\n\n CAM         \n\n ")
                    print("\(String(describing: cam))\n\n")
                }
            }
        }
    }

 }
