//
//  main.swift
//  JackAnalyzer
//
//  Created by 山崎宏哉 on 2022/01/05.
//  Copyright © 2022 山崎宏哉. All rights reserved.
//

import Foundation

class JackAnalyzer {
    
    static var tokenizer: JackTokenizer!
    static var fileHandle: FileHandle!
    static var compileList: [String] = []
    static var insertOffset = 0

    static func main() {
        let arguments = ProcessInfo().arguments
        let currentPath = FileManager.default.currentDirectoryPath
        
        guard arguments.count > 1 else {
            fatalError("target .vm file is not specified.")
        }

        let url = URL(fileURLWithPath: arguments[1])
        if !url.isDirectory {
            Self.compileSingleFile(url)
        } else {
            self.compileMultiFiles(url)
        }
    }

    private static func compileSingleFile(_ url: URL) {
        var fileName = url.lastPathComponent
        fileName.insert("X", at: fileName.firstIndex(of: ".")!)

        guard fileName.hasSuffix(".jack") else {
            fatalError("Selected file is not .jack format")
        }

        let outputFile = fileName.replacingOccurrences(of: "jack", with: "xml")
        let outputFileDir = url.deletingLastPathComponent().appendingPathComponent(outputFile)
        tokenizer = JackTokenizer(fileURL: url)
        createOutputFile(outputFileDir: outputFileDir)
        startParse()
    }

    private static func compileMultiFiles(_ url: URL) {
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
        var indentIndex = 0

        compileTokens(indentIndex: indentIndex)
        indentIndex += 2

        while tokenizer.hasMoreCommands() {
            tokenizer.advance()
            print("LINE = \(line)")
            print("\(tokenizer.tokenType.rawValue) : \(tokenizer.currentToken)")

            switch tokenizer.tokenType {
            case .KEYWORD:
                compileList.insert("<keyword> \(tokenizer.keyword()) </keyword>".indent(indentIndex), at: compileList.count-insertOffset)
            case .IDENTIFIER:
                compileList.insert("<identifier> \(tokenizer.identifier()) </identifier>".indent(indentIndex), at: compileList.count-insertOffset)
            case .SYMBOL:
                compileList.insert("<symbol> \(tokenizer.symbol()) </symbol>".indent(indentIndex), at: compileList.count-insertOffset)
            case .STRING_CONST:
                compileList.insert("<stringConstant> \(tokenizer.stringVal()) </stringConstant>".indent(indentIndex), at: compileList.count-insertOffset)
            case .INT_CONST:
                compileList.insert("<integerConstant> \(tokenizer.intVal()) </integerConstant>".indent(indentIndex), at: compileList.count-insertOffset)
            }

            print("=====================")
            line += 1
        }

        indentIndex -= 2
        writeOutToXml()
    }

    private static func createOutputFile(outputFileDir: URL) {

        FileManager
            .default
            .createFile(
                atPath: outputFileDir.path,
                contents: "".data(using: .utf8),
                attributes: nil)

        print("outputFileDir: \(outputFileDir)")
        fileHandle = FileHandle(forWritingAtPath: outputFileDir.path)!
    }

    private static func compileTokens(indentIndex: Int) {
        compileList.append("<tokens>")
        compileList.append("</tokens>")
        insertOffset += 1
    }

    private static func writeOutToXml() {
        for token in compileList {
            self.fileHandle.write(token.data(using: .utf8)!)
            self.fileHandle.write("\n".data(using: .utf8)!)
        }
    }

}

JackAnalyzer.main()
