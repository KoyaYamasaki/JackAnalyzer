//
//  JackAnalyzer.swift
//  JackAnalyzer
//
//  Created by 山崎宏哉 on 2022/02/08.
//  Copyright © 2022 山崎宏哉. All rights reserved.
//

import Foundation

class JackAnalyzer {
    
    var tokenizer: JackTokenizer
    var compilationEngine: CompilationEngine

    var currentToken: Token!
    var nextToken: Token!

    init(tokenizer: JackTokenizer, compilationEngine: CompilationEngine) {
        self.tokenizer = tokenizer
        self.compilationEngine = compilationEngine

        // Load two tokens and set currentToken & nextToken.
        self.advanceAndSetTokens()
        self.advanceAndSetTokens()
    }

    func startParse() -> Program {
        var program = Program(statements: [])
        repeat {
            program.statements.append(self.parseStatements())
            advanceAndSetTokens()
        } while tokenizer.hasMoreCommands()

        return program
    }

    private func advanceAndSetTokens() {
        currentToken = nextToken
        nextToken = self.tokenizer.advance()
    }

    private func expectPeek(tokenType: TokenType) -> Bool {
        return nextToken.tokenType == tokenType
    }

    private func parseStatements() -> Statement {
        switch currentToken.tokenType {
        case .LET:
            return parseLetStatement()
        case .RETURN:
            return parseReturnStatement()
        default:
            fatalError("Statement is unknown")
        }
    }

    private func parseLetStatement() -> Statement {
        let letToken = currentToken

        if expectPeek(tokenType: .IDENTIFIER) {
            advanceAndSetTokens()
        } else {
            unexpectedToken(expectedToken: .IDENTIFIER)
        }

        let letIdent = Identifier(token: currentToken, value: currentToken.tokenLiteral)

        if expectPeek(tokenType: .EQUAL) {
            advanceAndSetTokens()
        } else {
            unexpectedToken(expectedToken: .EQUAL)
        }

        advanceAndSetTokens()

        let letExpression = parseExpression()

        if expectPeek(tokenType: .SEMICOLON) {
            advanceAndSetTokens()
        } else {
            unexpectedToken(expectedToken: .SEMICOLON)
        }

        return LetStatement(token: letToken!, name: letIdent, expression: letExpression)
    }

    private func parseReturnStatement() -> Statement {
        let returnToken = currentToken

        if expectPeek(tokenType: .SEMICOLON) {
            advanceAndSetTokens()
            return ReturnStatement(token: returnToken!, expression: nil)
        }

        advanceAndSetTokens()

        let returnExpression = parseExpression()

        if expectPeek(tokenType: .SEMICOLON) {
            advanceAndSetTokens()
        } else {
            unexpectedToken(expectedToken: .SEMICOLON)
        }

        return ReturnStatement(token: returnToken!, expression: returnExpression)
    }

    private func parseExpression() -> Expression {
        var expression: Expression
        switch currentToken.tokenType {
        case .BOOLEAN:
            expression = parseBoolean()
        case .STRING_CONST:
            expression = parseStringLiteral()
        case .INT_CONST:
            expression = parseIntegerLiteral()
        case .IDENTIFIER:
            expression = parseIdentifier()
        default:
            expression = parseIdentifier()
        }

        advanceAndSetTokens()
        return expression
    }

    private func parseBoolean() -> Expression {
        return Boolean(token: currentToken, value: Bool(currentToken.tokenLiteral)!)
    }

    private func parseIdentifier() -> Expression {
        return Identifier(token: currentToken, value: currentToken.tokenLiteral)
    }

    private func parseStringLiteral() -> Expression {
        return StringLiteral(token: currentToken, value: currentToken.tokenLiteral)
    }

    private func parseIntegerLiteral() -> Expression {
        print("tokenLiteral", currentToken.tokenLiteral)
        return IntegerLiteral(token: currentToken, value: Int(currentToken.tokenLiteral)!)
    }

    private func unexpectedToken(expectedToken: TokenType) {
        fatalError("nextToken is not expected, expect=\(expectedToken), got=\(nextToken.tokenType)")
    }
}
