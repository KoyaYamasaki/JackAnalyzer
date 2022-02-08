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

    var input: String = ""

    private var position: Int = -1
    var readPosition: Int = 0
    private var currentChar: Character = " "

    private var tokenList: [String] = []

    convenience init(fileURL: URL) {
        guard let fileContents = try? String(contentsOf: fileURL) else {
            fatalError("File could not be read.")
        }
        self.init(contentStr: fileContents)
    }

    init(contentStr: String) {
        var commandByLine = contentStr.components(separatedBy: "\n")

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

        self.input = commandByLine.joined()
    }

    func hasMoreCommands() -> Bool {
        return position + 1 != self.input.count
    }

    func advance() -> Token {
        var token: Token

        self.skipWhiteSpace()

        if TokenType.symbolSets.contains(currentChar) {
            token = Token(tokenType: TokenType(rawValue: String(currentChar))!, tokenLiteral: String(currentChar))
        } else if currentChar == "\"" {
            return Token(tokenType: .STRING_CONST, tokenLiteral: self.readString())
        } else if currentChar.isLetter {
            let str = self.readIdentifier()
            if TokenType.keywordSets.contains(str) {
                return Token(tokenType: TokenType(rawValue: str)!, tokenLiteral: str)
            } else {
                return Token(tokenType: .IDENTIFIER, tokenLiteral: str)
            }
        } else if currentChar.isNumber {
            return Token(tokenType: .INT_CONST, tokenLiteral: self.readNumber())
        } else {
            fatalError("Token is unknown.")
        }

        self.readChar()
        return token
    }

    func getNextCommand() -> String {
        return tokenList[position+1]
    }

    private func readChar() {
        if self.readPosition >= self.input.count {
            self.currentChar = "0"
        } else {
            self.currentChar = Array(self.input)[self.readPosition]
        }
        self.position = self.readPosition
        self.readPosition += 1
    }

    private func skipWhiteSpace() {
        while self.currentChar.isWhitespace || self.currentChar == "\t" || self.currentChar == "\n" || self.currentChar == "\r" {
            readChar()
        }
    }

    private func readNumber() -> String {
        let position = self.position
        while self.currentChar.isNumber {
            self.readChar()
        }
        return String(Array(self.input)[position...self.position])
    }

    private func readString() -> String {
        var token: String = ""
        while !TokenType.symbolSets.contains(self.currentChar) {
            token.append(self.currentChar)
            self.readChar()
        }
        return token
    }

    private func readIdentifier() -> String {
        var token: String = ""
        while self.currentChar.isLetter {
            token.append(self.currentChar)
            self.readChar()
        }
        return token
    }
}
