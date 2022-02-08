//
//  JackAnalyzer.swift
//  JackAnalyzer
//
//  Created by 山崎宏哉 on 2022/02/08.
//  Copyright © 2022 山崎宏哉. All rights reserved.
//

import Foundation

class JackAnalyzer {
    
    var tokenizer: JackTokenizer!
    var compilationEngine: CompilationEngine!

    func compileSingleFile(_ url: URL) {
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

    func compileMultiFiles(_ url: URL) {
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

    private func startParse() {
        while tokenizer.hasMoreCommands() {
            self.parseStatements(token: tokenizer.advance())
        }

//        compilationEngine.outPutToXml()
    }

    private func parseStatements(token: Token) {
        switch token.tokenType {
        case .LET:
            parseLetStatement()
        default:
            print("parseStatements default")
        }
    }

    private func parseLetStatement() {
        print("parseLetStatement")
    }
}
