//
//  JackTokenizer.swift
//  JackAnalyzer
//
//  Created by 山崎宏哉 on 2022/01/05.
//  Copyright © 2022 山崎宏哉. All rights reserved.
//

import Foundation

class JackTokenizer {

    var currentToken = ""

    private let preservedDelimiters: Set<Character> =
        ["{", "}", "(", ")", "[", "]", ".", ",", ";", "+", "-", "*", "/",
    "&", "|", "<", ">", "=", "~"]
    private var position: Int = -1
    private var tokenList: [String] = []

    init(fileURL: URL) {

        guard let fileContents = try? String(contentsOf: fileURL) else {
            fatalError("File could not be read.")
        }

        var commandByLine = fileContents.components(separatedBy: "\n")

        // Remove comment lines.
        commandByLine = commandByLine.filter {
            !$0.hasPrefix("//") && !$0.hasPrefix("/*")
        }

        // Remove Same line comment
        commandByLine = commandByLine.map({
            if let commentIndex = $0.range(of: "//") {
                return String($0[..<commentIndex.lowerBound])
            } else { return $0 }
        })

        // Remove spaces.
        commandByLine = commandByLine.map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })

        // Remove line break lines.
        commandByLine = commandByLine.filter({ $0 != "\r" && !$0.isEmpty })
        
        for line in commandByLine {
            var token = ""
            line.forEach { char in
                if char == " " {
                    if token.contains("\"") {
                        token.append(char)
                    } else {
                        if !token.isEmpty {
                            tokenList.append(token)
                            token = ""
                        }
                    }
                    return
                }
                
                if preservedDelimiters.contains(char) {
                    if !token.isEmpty {
                        tokenList.append(token)
                        token = ""
                    }
                    tokenList.append(String(char))
                } else {
                    token.append(char)
                }
                
            }
            if !token.isEmpty {
                tokenList.append(token)
            }
        }

        print(tokenList)
    }

    var tokenType: TokenType {
        if Int(currentToken) != nil {
            return .INT_CONST
        }

        if currentToken.contains("\"") {
            return .STRING_CONST
        }

        switch currentToken {
        case "class", "constructor", "function", "method", "field", "static",
             "var", "int", "char", "boolean", "void", "true", "false", "null",
             "this", "let", "do", "if", "else", "while", "return":
            return .KEYWORD
        case "{", "}", "(", ")", "[", "]", ".", ",", ";", "+", "-", "*", "/",
             "&", "|", "<", ">", "=", "~":
            return .SYMBOL
        default:
            return .IDENTIFIER
        }
    }

    func hasMoreCommands() -> Bool {
        return position + 1 != tokenList.count
    }

    func advance() {
        if hasMoreCommands() {
            position += 1
            currentToken = tokenList[position]
        }
    }

    func keyword() -> String {
        return currentToken
    }

    func symbol() -> String {
        return currentToken
    }

    func identifier() -> String {
        return currentToken
    }

    func intVal() -> Int {
        if let intToken = Int(currentToken) {
            return intToken
        } else {
            fatalError("currentToken is not int value.")
        }
    }

    func stringVal() -> String {
        if currentToken.contains("\"") {
        }

        return ""
    }
}
