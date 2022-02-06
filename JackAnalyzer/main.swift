//
//  main.swift
//  JackAnalyzer
//
//  Created by 山崎宏哉 on 2022/01/05.
//  Copyright © 2022 山崎宏哉. All rights reserved.
//

import Foundation

class Main {
    static func main() {
        let arguments = ProcessInfo().arguments
        let currentPath = FileManager.default.currentDirectoryPath
        
        guard arguments.count > 1 else {
            fatalError("target .vm file is not specified.")
        }

        let url = URL(fileURLWithPath: arguments[1])
        if !url.isDirectory {
            JackAnalyzer.compileSingleFile(url)
        } else {
            JackAnalyzer.compileMultiFiles(url)
        }
    }
}

class JackAnalyzer {
    
    static var tokenizer: JackTokenizer!
    static var compilationEngine: CompilationEngine!

    static func compileSingleFile(_ url: URL) {
        var fileName = url.lastPathComponent
        fileName.insert("X", at: fileName.firstIndex(of: ".")!)

        guard fileName.hasSuffix(".jack") else {
            fatalError("Selected file is not .jack format")
        }

        let outputFile = fileName.replacingOccurrences(of: "jack", with: "xml")
        let outputFileDir = url.deletingLastPathComponent().appendingPathComponent(outputFile)
        tokenizer = JackTokenizer(fileURL: url)
        compilationEngine = CompilationEngine(outputFileDir: outputFileDir)
        startParse()
    }

    static func compileMultiFiles(_ url: URL) {
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents =
                try FileManager
                    .default
                    .contentsOfDirectory(
                        at: url,
                        includingPropertiesForKeys: nil
            )
            let jackFileUrls = directoryContents.filter{ $0.pathExtension == "jack" }
            let outputFile = url.lastPathComponent.appending(".xml")
            
            guard jackFileUrls.count != 0 else {
                fatalError("There has not contained .jack format file")
            }
            
            let outputFileDir = jackFileUrls.first!.deletingLastPathComponent().appendingPathComponent(outputFile)
            
            for jackUrl in jackFileUrls {

            }
            
        } catch {
            fatalError("Unable to get list of files inside the directory")
        }
    }

    private static func startParse() {
        var line = 1

        while tokenizer.hasMoreCommands() {
            tokenizer.advance()
            print("LINE = \(line)")
            print("\(tokenizer.tokenType.rawValue) : \(tokenizer.currentToken)")

            print("=====================")
            line += 1
        }

        compilationEngine.outPutToXml()
    }
}

Main.main()
