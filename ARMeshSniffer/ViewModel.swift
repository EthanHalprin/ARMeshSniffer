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
    var pdfData: Data?

    
    init() {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            self.url = dir.appendingPathComponent(self.filename)
        }
    }
    
    /// Encode a single sniffed block from a frame & save it to a binary file
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
    
    /// Reads a single sniffed block from file & decode it to a SniffBlocked
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
        
        if pdfData == nil {
            pdfData = data
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
   
    /// Display in output what was recorded sequentially frame by frame with index
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

    /// Saves Data to pdf file in Files app on device
    func savePDF(presenter vc: UIViewController) {
            if let documentData = self.pdfData {
            DispatchQueue.main.async {
                let activityController = UIActivityViewController(activityItems: [documentData],
                                                                  applicationActivities: nil)
                vc.present(activityController, animated: true, completion: nil)
            }
        }
    }

 }
