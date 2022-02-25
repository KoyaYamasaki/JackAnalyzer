//
//  Token.swift
//  JackAnalyzer
//
//  Created by 山崎宏哉 on 2022/01/06.
//  Copyright © 2022 山崎宏哉. All rights reserved.
//

import Foundation

struct Token {
    let tokenType: TokenType
    let tokenLiteral: String

    init(tokenType: TokenType, tokenLiteral: String) {
        self.tokenType = tokenType
        self.tokenLiteral = tokenLiteral
    }

    var getEscapeCharacters: String {
        if tokenType == .LANGLE {
            return "&lt;"
        }
        if tokenType == .RANGLE {
            return "&gt;"
        }
        if tokenType == .AMPERSAND {
            return "&amp;"
        }

        return tokenLiteral
    }
}

enum TokenType: String {
    // KEYWORD
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

    // SYMBOL
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

    case IDENTIFIER = "IDENTIFIER"
    case CALL_EXPRESSION = "CALL_EXPRESSION"
    case PREFIX_EXPRESSION = "PREFIX_EXPRESSION"
    case INFIX_EXPRESSION = "INFIX_EXPRESSION"
    case INT_CONST = "INT_CONST"
    case STRING_CONST = "STRING_CONST"

    static var keywordSets: Set<String> {
        return ["class", "constructor", "function", "method", "field", "static", "var", "int", "char", "boolean", "void", "true", "false",
                "null", "this", "let", "do", "if", "else", "while", "return"]
    }

    static var symbolSets: Set<Character> {
        return ["{", "}", "(", ")", "[", "]", ".", ",", ";", "+", "-", "*", "/",
                "&", "|", "<", ">", "=", "~"]
    }
}
