//
//  Parser.swift
//  Parser
//
//  Created by 山崎宏哉 on 2022/02/08.
//  Copyright © 2022 山崎宏哉. All rights reserved.
//

import Foundation

class Parser {
    
    var lexer: Lexer
    var compilationEngine: CompilationEngine

    var program: Program!
    var currentToken: Token!
    var nextToken: Token!

    init(lexer: Lexer, compilationEngine: CompilationEngine) {
        self.lexer = lexer
        self.compilationEngine = compilationEngine

        // Load two tokens and set currentToken & nextToken.
        advanceAndSetTokens()
        advanceAndSetTokens()
    }

    func startParse() -> Program {
        var cls = parseClass()

        repeat {
            cls.functions.append(self.parseFunction())
            advanceAndSetTokens()
        } while lexer.hasMoreCommands()

        return Program(cls: cls)
    }

    private func parseFunction() -> Function {
        var function: Function

        if currentToken.tokenType != .FUNCTION {
            function = makeProvisionalFunction()
        } else {
            let fnToken = currentToken

            self.advanceAndSetTokens()

            let returnType = currentToken

            if expectPeek(tokenType: .IDENTIFIER) {
                self.advanceAndSetTokens()
            } else {
                unexpectedToken(expectedToken: .IDENTIFIER)
            }

            let fnNameToken = Token(tokenType: .IDENTIFIER, tokenLiteral: currentToken.tokenLiteral)
            let fnName = Identifier(token: fnNameToken, value: fnNameToken.tokenLiteral)

            self.advanceAndSetTokens()
            function = Function(token: fnToken!, returnType: returnType!, name: fnName, statements: [])
        }

        repeat {
            if let stmt = self.parseStatements() {
                function.statements.append(stmt)
            }
            advanceAndSetTokens()
        } while !expectPeek(tokenType: .FUNCTION) && lexer.hasMoreCommands()

        return function
    }

    private func makeProvisionalFunction() -> Function {
        let fnToken = Token(tokenType: .FUNCTION, tokenLiteral: "function")
        let returnType = Token(tokenType: .VOID, tokenLiteral: "void")
        let fnNameToken = Token(tokenType: .IDENTIFIER, tokenLiteral: "main")
        let fnName = Identifier(token: fnNameToken, value: fnNameToken.tokenLiteral)

        return Function(token: fnToken, returnType: returnType, name: fnName, statements: [])
    }

    private func parseClass() -> Class {
        if currentToken.tokenType != .CLASS {
            return makeProvisionalClass()
        }

        let clsToken = currentToken

        if expectPeek(tokenType: .IDENTIFIER) {
            self.advanceAndSetTokens()
        } else {
            unexpectedToken(expectedToken: .IDENTIFIER)
        }

        let clsNameToken = Token(tokenType: .IDENTIFIER, tokenLiteral: currentToken.tokenLiteral)
        let clsName = Identifier(token: clsNameToken, value: clsNameToken.tokenLiteral)

        if expectPeek(tokenType: .LBLACE) {
            self.advanceAndSetTokens()
        } else {
            unexpectedToken(expectedToken: .IDENTIFIER)
        }

        self.advanceAndSetTokens()

        return Class(token: clsToken!, name: clsName, functions: [])
    }

    private func makeProvisionalClass() -> Class {
        let clsToken = Token(tokenType: .CLASS, tokenLiteral: "class")

        let clsNameToken = Token(tokenType: .IDENTIFIER, tokenLiteral: "Main")

        let clsName = Identifier(token: clsNameToken, value: clsNameToken.tokenLiteral)

        return Class(token: clsToken, name: clsName, functions: [])
    }

    private func advanceAndSetTokens() {
        currentToken = nextToken
        nextToken = self.lexer.advance()
    }

    private func expectPeek(tokenType: TokenType) -> Bool {
        return nextToken.tokenType == tokenType
    }

    private func parseStatements() -> Statement? {
        switch currentToken.tokenType {
        case .LET:
            return parseLetStatement()
        case .RETURN:
            return parseReturnStatement()
        case .DO:
            return parseDoStatement()
        default:
            print("currentTokenType : \(currentToken.tokenType)")
            return nil
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

        return LetStatement(token: letToken!, name: letIdent, expression: letExpression!)
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

    private func parseDoStatement() -> Statement {
        let doToken = currentToken

        if expectPeek(tokenType: .IDENTIFIER) {
            advanceAndSetTokens()
        } else {
            unexpectedToken(expectedToken: .IDENTIFIER)
        }

        var clsName: Identifier?
        var fnName: Identifier

        if expectPeek(tokenType: .DOT) {
            clsName = Identifier(token: currentToken, value: currentToken.tokenLiteral)
            advanceAndSetTokens()
            if expectPeek(tokenType: .IDENTIFIER) {
                advanceAndSetTokens()
            } else {
                unexpectedToken(expectedToken: .IDENTIFIER)
            }
        }

        fnName = Identifier(token: currentToken, value: currentToken.tokenLiteral)

        if expectPeek(tokenType: .LPARENTHESIS) {
            advanceAndSetTokens()
        }

        var doStmt = DoStatement(token: doToken!, clsName: clsName, fnName: fnName, arguments: [])
        repeat {
            advanceAndSetTokens()
            if let exp = self.parseExpression() {
                doStmt.arguments.append(exp)
            }
        } while !expectPeek(tokenType: .SEMICOLON)

        return doStmt
    }

    private func parseExpression() -> Expression? {
        var expression: Expression
        print("tokenType : \(currentToken.tokenType)")
        switch currentToken.tokenType {
        case .TRUE, .FALSE:
            expression = parseBoolean()
        case .STRING_CONST:
            expression = parseStringLiteral()
        case .INT_CONST:
            expression = parseIntegerLiteral()
        case .IDENTIFIER:
            expression = parseIdentifier()
        default:
            return nil
        }

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
