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

    var program: Program!
    var currentToken: Token!
    var nextToken: Token!

    init(lexer: Lexer) {
        self.lexer = lexer

        // Load two tokens and set currentToken & nextToken.
        advanceAndSetTokens()
        advanceAndSetTokens()
    }

    func startParse() -> Program {
        var cls = parseClass()

        repeat {
            cls.functions.append(self.parseFunction())
        } while expectPeek(tokenType: .FUNCTION)

        return Program(cls: cls)
    }

    private func parseFunction() -> Function {
        var function: Function

        if !expectPeek(tokenType: .FUNCTION) {
            print("makeProvisionalFunction")
            function = Function.makeProvisionalFunction()
        } else {
            self.advanceAndSetTokens()

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

            if expectPeek(tokenType: .LPARENTHESIS) {
                self.advanceAndSetTokens()
            }

            if expectPeek(tokenType: .RPARENTHESIS) {
                self.advanceAndSetTokens()
            }

            if expectPeek(tokenType: .LBLACE) {
                self.advanceAndSetTokens()
            }

            var varStatements: [VarStatement] = []
            
            while expectPeek(tokenType: .VAR) {
                self.advanceAndSetTokens()
                varStatements.append(parseVarStatement())
            }

            function = Function(token: fnToken!, returnType: returnType!, name: fnName, parameters: [], vars: varStatements, statements: [])
        }

        // Need to repeat at least once.
        repeat {
            if let stmt = self.parseStatements() {
                function.statements.append(stmt)
            }
            advanceAndSetTokens()
        } while !expectPeek(tokenType: .FUNCTION) && lexer.hasMoreCommands()

        return function
    }

    private func parseClass() -> Class {
        if currentToken.tokenType != .CLASS {
            return Class.makeProvisionalClass()
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
            unexpectedToken(expectedToken: .LBLACE)
        }

        var varStatements: [VarStatement] = []
        while nextToken.tokenType == .FIELD || nextToken.tokenType == .STATIC || nextToken.tokenType == .VAR {
            self.advanceAndSetTokens()
            varStatements.append(parseVarStatement())
        }
        
        return Class(token: clsToken!, name: clsName, vars: varStatements, functions: [])
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
        case .IF:
            return parseIfStatement()
        default:
            print("currentTokenType : \(currentToken.tokenType)")
            return nil
        }
    }

    private func parseVarStatement() -> VarStatement {
        let varToken = currentToken

        self.advanceAndSetTokens()
        let typeToken = currentToken

        var namesArray: [Identifier] = []
        while expectPeek(tokenType: .IDENTIFIER) {
            self.advanceAndSetTokens()
            namesArray.append(Identifier(token: currentToken!, value: currentToken.tokenLiteral))
            self.advanceAndSetTokens()
        }

        return VarStatement(token: varToken!, type: typeToken!, names: namesArray)
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

    private func parseIfStatement() -> Statement {
        let ifToken = currentToken

        if expectPeek(tokenType: .LPARENTHESIS) {
            self.advanceAndSetTokens()
        }

        advanceAndSetTokens()

        let condition = parseExpression()

        var ifStmt = IfStatement(token: ifToken!, condition: condition!, consequence: [], alternative: nil)

        if expectPeek(tokenType: .RPARENTHESIS) {
            self.advanceAndSetTokens()
        }

        if expectPeek(tokenType: .LBLACE) {
            self.advanceAndSetTokens()
        }

        while !expectPeek(tokenType: .RBLACE) && lexer.hasMoreCommands() {
            if let stmt = self.parseStatements() {
                ifStmt.consequence.append(stmt)
            } else {
                self.advanceAndSetTokens()
            }
        }

        self.advanceAndSetTokens()

        if expectPeek(tokenType: .ELSE) {
            ifStmt.alternative = []
            self.advanceAndSetTokens()
            if expectPeek(tokenType: .LBLACE) {
                self.advanceAndSetTokens()
            }

            while !expectPeek(tokenType: .RBLACE) && lexer.hasMoreCommands() {
                if let stmt = self.parseStatements() {
                    ifStmt.alternative?.append(stmt)
                } else {
                    self.advanceAndSetTokens()
                }
            }
        }

        return ifStmt
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
