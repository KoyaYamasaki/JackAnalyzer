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
    var previousToken = ""

    private let symbolSets: Set<Character> =
        ["{", "}", "(", ")", "[", "]", ".", ",", ";", "+", "-", "*", "/",
    "&", "|", "<", ">", "=", "~"]
    private var position: Int = -1
    private var tokenList: [String] = []

    init(fileURL: URL) {

        guard let fileContents = try? String(contentsOf: fileURL) else {
            fatalError("File could not be read.")
        }

        var commandByLine = fileContents.components(separatedBy: "\n")

        // Remove spaces.
        commandByLine = commandByLine.map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })

        // Remove comment lines.
        commandByLine = commandByLine.filter {
            !$0.hasPrefix("//") && !$0.hasPrefix("/**")
        }

        // Remove Same line comment
        commandByLine = commandByLine.map({
            if let commentIndex = $0.range(of: "//") {
                return String($0[..<commentIndex.lowerBound])
            } else { return $0 }
        })

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
                
                if symbolSets.contains(char) {
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

        if Keyword(rawValue: currentToken) != nil {
            return .KEYWORD
        }

        if Symbol(rawValue: currentToken) != nil {
            return .SYMBOL
        }

        return .IDENTIFIER
    }

    func hasMoreCommands() -> Bool {
        return position + 1 != tokenList.count
    }

    func advance() {
        previousToken = currentToken

        if hasMoreCommands() {
            position += 1
            currentToken = tokenList[position]
        }
    }

    func getNextCommand() -> String {
        return tokenList[position+1]
    }

    func keyword() -> Keyword {
        guard let keyword = Keyword(rawValue: currentToken) else {
            fatalError("currentToken is not keyword")
        }

        return keyword
    }

    func symbol() -> Symbol {
        guard let symbol = Symbol(rawValue: currentToken) else {
            fatalError("currentToken is not symbol")
        }

        return symbol
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
        guard currentToken.contains("\"") else {
            fatalError("currentToken is not string value.")
        }

        let stringVal = currentToken.replacingOccurrences(of: "\"", with: "")
        return stringVal
    }
}
