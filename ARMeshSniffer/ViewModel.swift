//
//  ViewModel.swift
//  ARMeshSniffer
//
//  Created by Ethan on 09/12/2020.
//

import Foundation
import UIKit

class ViewModel {
    
    var filename = "armesh_results"
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
    
    func write(_ text: String) {
        if let dir = FileManager.default.urls(for: .documentDirectory,
                                              in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(self.filename)
            do {
                try text.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {
                print("ERROR: Could not write to file")
            }
        }
    }
    
    func read() -> String? {
        var text: String?

        if let dir = FileManager.default.urls(for: .documentDirectory,
                                              in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(self.filename)
            do {
                text = try String(contentsOf: fileURL, encoding: .utf8)
            }
            catch {
                print("ERROR: Could not read file")
            }
        }
        return text
    }
}
