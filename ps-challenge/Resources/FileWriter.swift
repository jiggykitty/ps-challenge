//
//  FileWriter.swift
//  ps-challenge
//
//  Created by Cagri Sahan on 3/21/18.
//  Copyright © 2018 Cagri Sahan. All rights reserved.
//

enum FileWriterError: Error {
    case writeFileError
    case readFileError
    case demoDataReadError
}

import Foundation

class FileWriter {
    
    // MARK: Variables
    static let shared = FileWriter()
    var decoder: JSONDecoder?
    var encoder: JSONEncoder?
    let fileManager = FileManager.default
    
    // MARK: Functions
    private init() { }
    
    func readDemoData() throws -> [MyPin] {
        let path = Bundle.main.path(forResource: "demo-locations", ofType: "json")
        decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path!))
            let list = try decoder!.decode([MyPin].self, from: data)
            return list
        }
        catch { throw FileWriterError.demoDataReadError }
    }
    
    func localDataExists() -> Bool {
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let contents = try! FileManager.default.contentsOfDirectory(atPath: documentDirectory.path)
        return !contents.isEmpty
    }
    
    func writeData(pinList: [MyPin]) throws {
        encoder = JSONEncoder()
        do {
            let data = try encoder!.encode(pinList)
            let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentDirectory.appendingPathComponent("pins")
            try data.write(to: fileURL)
        }
        catch { throw FileWriterError.writeFileError}
    }
    
    func readData() throws -> [MyPin] {
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirectory.appendingPathComponent("pins")
        do {
            let data = try Data(contentsOf: fileURL)
            decoder = JSONDecoder()
            let list = try decoder!.decode([MyPin].self, from: data)
            return list
        }
        catch { throw FileWriterError.readFileError }
    }
}
