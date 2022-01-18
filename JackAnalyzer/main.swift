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
    static var compilationEngine: CompilationEngine!
    static var currentKeyword: Keyword = .CLASS
    static var additionalOffset: [String: Int] = [";": 0, "}": 0]
    static var previousSymbol: Symbol = .NONE

    static var isCurrentStatement: Bool {
        return currentKeyword == .WHILE || currentKeyword == .IF || currentKeyword == .DO || currentKeyword == .LET
    }

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
        compilationEngine = CompilationEngine(outputFileDir: outputFileDir)
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

        while tokenizer.hasMoreCommands() {
            tokenizer.advance()
            print("LINE = \(line)")
            print("\(tokenizer.tokenType.rawValue) : \(tokenizer.currentToken)")

            switch tokenizer.tokenType {
            case .KEYWORD:
                if tokenizer.keyword() == .CLASS {
                    currentKeyword = tokenizer.keyword()
                    compilationEngine.compileClass()
                }

                if tokenizer.keyword() == .FUNCTION {
                    currentKeyword = tokenizer.keyword()
                    compilationEngine.compileSubroutine()
                }

                if tokenizer.keyword() == .VAR {
                    currentKeyword = tokenizer.keyword()
                    compilationEngine.compileVarDec()
                }

                if tokenizer.keyword() == .LET ||
                    tokenizer.keyword() == .DO ||
                    tokenizer.keyword() == .IF ||
                    tokenizer.keyword() == .WHILE {
                    if !isCurrentStatement {
                        compilationEngine.compileStatements()
                    }

                    currentKeyword = tokenizer.keyword()

                    if tokenizer.keyword() == .LET {
                        compilationEngine.compileLet()
                    }

                    if tokenizer.keyword() == .DO {
                        compilationEngine.compileDo()
                    }

                    if tokenizer.keyword() == .IF {
                        compilationEngine.compileIf()
                    }

                    if tokenizer.keyword() == .WHILE {
                        compilationEngine.compileWhile()
                    }
                }

                if tokenizer.keyword() == .RETURN {
                    compilationEngine.compileReturn()
                    currentKeyword = .CLASS
                }
                compilationEngine.addToCompileTokenList(token: ("<keyword> \(tokenizer.keyword().rawValue) </keyword>"))
            case .IDENTIFIER:
                if currentKeyword == .WHILE || currentKeyword == .IF {
                    compilationEngine.compileTerm()
                    compilationEngine.addToCompileTokenList(token: ("<identifier> \(tokenizer.identifier()) </identifier>"))
                    compilationEngine.endCurrentTag()
                    break
                }

                if previousSymbol == .EQUAL {
                    compilationEngine.compileExpression()
                    if tokenizer.getNextCommand() == "." {
                        compilationEngine.compileTerm()
                        compilationEngine.addToCompileTokenList(token: ("<identifier> \(tokenizer.identifier()) </identifier>"))
                        additionalOffset[";"]! += 2
                    } else if isFourArithOperations(tokenizer.getNextCommand()) {
                        compilationEngine.compileTerm()
                        compilationEngine.addToCompileTokenList(token: ("<identifier> \(tokenizer.identifier()) </identifier>"))
                        additionalOffset[";"]! += 1
                        compilationEngine.endCurrentTag()
                    } else {
                        compilationEngine.compileTerm()
                        compilationEngine.addToCompileTokenList(token: ("<identifier> \(tokenizer.identifier()) </identifier>"))
                        compilationEngine.endCurrentTagBy(2)
                    }
                    
                    previousSymbol = .NONE
                    break
                }

                if tokenizer.previousToken != "let" && tokenizer.previousToken != "var" {
                    if tokenizer.getNextCommand() == "[" {
                        compilationEngine.compileTerm()
                        compilationEngine.addToCompileTokenList(token: ("<identifier> \(tokenizer.identifier()) </identifier>"))
                        additionalOffset[";"]! += 1
                        break
                    }
                }

                if isFourArithOperations(previousSymbol.rawValue) {
                    compilationEngine.compileTerm()
                    compilationEngine.addToCompileTokenList(token: ("<identifier> \(tokenizer.identifier()) </identifier>"))
                    compilationEngine.endCurrentTag()
                    break
                }

                if previousSymbol == .LPARENTHESIS || previousSymbol == .LBLACKET {
                    compilationEngine.compileExpression()
                    compilationEngine.compileTerm()
                    compilationEngine.addToCompileTokenList(token: ("<identifier> \(tokenizer.identifier()) </identifier>"))
                    if isFourArithOperations(tokenizer.getNextCommand()) {
                        compilationEngine.endCurrentTag()
                        additionalOffset[";"]! += 1
                        break
                    } else {
                        compilationEngine.endCurrentTagBy(2)
                        break
                    }
                }

                compilationEngine.addToCompileTokenList(token: ("<identifier> \(tokenizer.identifier()) </identifier>"))
            case .SYMBOL:
                if tokenizer.symbol() == .LBLACE { // {
                    if currentKeyword == .FUNCTION {
                        compilationEngine.compileSubroutineBody()
                        compilationEngine.addToCompileTokenList(token: ("<symbol> \(tokenizer.symbol().rawValue) </symbol>"))
                        previousSymbol = tokenizer.symbol()
                        break
                    }

                    if currentKeyword == .WHILE || currentKeyword == .IF {
                        compilationEngine.addToCompileTokenList(token: ("<symbol> \(tokenizer.symbol().rawValue) </symbol>"))
                        compilationEngine.compileStatements()
                        additionalOffset["}"]! += 1
                        previousSymbol = tokenizer.symbol()
                        break
                    }
                }

                if tokenizer.symbol() == .LPARENTHESIS { // (
                    compilationEngine.addToCompileTokenList(token: ("<symbol> \(tokenizer.symbol().rawValue) </symbol>"))
                    if currentKeyword == .FUNCTION {
                        compilationEngine.compileParameterList()
                    }

                    if currentKeyword == .DO || currentKeyword == .LET {
                        compilationEngine.compileExpressionList()
                    }

                    if currentKeyword == .WHILE || currentKeyword == .IF {
                        compilationEngine.compileExpression()
                    }

                    previousSymbol = tokenizer.symbol()
                    break
                }

                if tokenizer.symbol() == .RPARENTHESIS { // )

                    if currentKeyword == .LET || currentKeyword == .DO || currentKeyword == .WHILE {
                        compilationEngine.endCurrentTag()
                    }

                    compilationEngine.addToCompileTokenList(token: ("<symbol> \(tokenizer.symbol().rawValue) </symbol>"))

                    previousSymbol = tokenizer.symbol()
                    break
                }

                if tokenizer.symbol() == .LBLACKET { // [
                    compilationEngine.addToCompileTokenList(token: ("<symbol> \(tokenizer.symbol().rawValue) </symbol>"))

                    previousSymbol = tokenizer.symbol()
                    break
                }

                if tokenizer.symbol() == .RBLACKET { // ]
//                    compilationEngine.endCurrentTag()

                    compilationEngine.addToCompileTokenList(token: ("<symbol> \(tokenizer.symbol().rawValue) </symbol>"))
                    previousSymbol = tokenizer.symbol()
                    break
                }

                if tokenizer.symbol() == .DOT {

                    compilationEngine.addToCompileTokenList(token: ("<symbol> \(tokenizer.symbol().rawValue) </symbol>"))
                    previousSymbol = tokenizer.symbol()
                    break
                }

                if tokenizer.symbol() == .RBLACE { // }
                    compilationEngine.endCurrentTagBy(additionalOffset["}"]!)
                    compilationEngine.addToCompileTokenList(token: ("<symbol> \(tokenizer.symbol().rawValue) </symbol>"))
                    compilationEngine.endCurrentTag()
                    additionalOffset["}"] = 0
                    previousSymbol = tokenizer.symbol()
                    break
                }

                if tokenizer.symbol() == .EQUAL {
                    compilationEngine.addToCompileTokenList(token: ("<symbol> \(tokenizer.symbol().rawValue) </symbol>"))
                    previousSymbol = tokenizer.symbol()
                    break
                }

                if tokenizer.symbol() == .SEMICOLON {
                    compilationEngine.endCurrentTagBy(additionalOffset[";"]!)
                    compilationEngine.addToCompileTokenList(token: ("<symbol> \(tokenizer.symbol().rawValue) </symbol>"))
                    compilationEngine.endCurrentTag()
                    additionalOffset[";"] = 0
                    previousSymbol = .SEMICOLON
                    break
                }

                compilationEngine.addToCompileTokenList(token: ("<symbol> \(tokenizer.symbol().rawValue) </symbol>"))
                previousSymbol = tokenizer.symbol()
            case .STRING_CONST:
                if previousSymbol == .LPARENTHESIS || previousSymbol == .EQUAL {
                    compilationEngine.compileExpression()
                    compilationEngine.compileTerm()
                    compilationEngine.addToCompileTokenList(token: ("<stringConstant> \(tokenizer.stringVal()) </stringConstant>"))
                    compilationEngine.endCurrentTagBy(2)
//                    compilationEngine.endCurrentTag()
//                    additionalOffset += 1
                    break
                }

                compilationEngine.compileTerm()
                compilationEngine.addToCompileTokenList(token: ("<stringConstant> \(tokenizer.stringVal()) </stringConstant>"))
                compilationEngine.endCurrentTag()
            case .INT_CONST:
                if previousSymbol == .LPARENTHESIS || previousSymbol == .EQUAL {
                    compilationEngine.compileExpression()
                    compilationEngine.compileTerm()
                    compilationEngine.addToCompileTokenList(token: ("<integerConstant> \(tokenizer.intVal()) </integerConstant>"))
                    compilationEngine.endCurrentTagBy(2)
//                    additionalOffset += 1
                    break
                }

                compilationEngine.compileTerm()
                compilationEngine.addToCompileTokenList(token: ("<integerConstant> \(tokenizer.intVal()) </integerConstant>"))
                compilationEngine.endCurrentTag()
            }

            print("=====================")
            line += 1
        }

        compilationEngine.outPutToXml()
    }

    private static func isFourArithOperations(_ symbol: String) -> Bool {
        return symbol == "+" || symbol == "-" || symbol == "/" || symbol == "*"
    }
}

JackAnalyzer.main()
