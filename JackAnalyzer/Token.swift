//
//  Token.swift
//  JackAnalyzer
//
//  Created by 山崎宏哉 on 2022/01/06.
//  Copyright © 2022 山崎宏哉. All rights reserved.
//

import Foundation

protocol TokenLiteral {
    associatedtype T

    func literal() -> String
}

struct Token<T> {
    let tokenType: TokenType
    let tokenLiteral: T

    init(tokenType: TokenType, tokenLiteral: T) {
        self.tokenType = tokenType
        self.tokenLiteral = tokenLiteral
    }
}

enum TokenType: String {
    case KEYWORD = "KEYWORD"
    case SYMBOL = "SYMBOL"
    case IDENTIFIER = "IDENTIFIER"
    case INT_CONST = "INT_CONST"
    case STRING_CONST = "STRING_CONST"
}

enum Keyword: String, TokenLiteral {
    typealias T = Keyword

    case CLASS = "class"
    case CONSTRUCTOR = "constructor"
    case FUNCTION = "function"
    case METHOD = "method"
    case FIELD = "field"
    case STATIC = "static"
    case VAR = "var"
    case INT = "int"
    case CHAR = "char"
    case BOOLEAN = "boolean"
    case VOID = "void"
    case TRUE = "true"
    case FALSE = "false"
    case NULL = "null"
    case THIS = "this"
    case LET = "let"
    case DO = "do"
    case IF = "if"
    case ELSE = "else"
    case WHILE = "while"
    case RETURN = "return"

    func literal() -> String {
        return self.rawValue
    }
}

enum Symbol: String, TokenLiteral {
    typealias T = Symbol

    case LBLACE = "{"
    case RBLACE = "}"
    case LPARENTHESIS = "("
    case RPARENTHESIS = ")"
    case LBLACKET = "["
    case RBLACKET = "]"
    case DOT = "."
    case COMMA = ","
    case SEMICOLON = ";"
    case PLUS = "+"
    case MINUS = "-"
    case ASTERISK = "*"
    case SLASH = "/"
    case AMPERSAND = "&"
    case PIPE = "|"
    case LANGLE = "<"
    case RANGLE = ">"
    case EQUAL = "="
    case TILDE = "~"
    case NONE = ""

    func literal() -> String {
        return self.rawValue
    }

    static var symbolSets: Set<Character> {
        return ["{", "}", "(", ")", "[", "]", ".", ",", ";", "+", "-", "*", "/",
                "&", "|", "<", ">", "=", "~"]
    }
        
}
