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
        } while expectPeek(tokenType: .FUNCTION) || expectPeek(tokenType: .METHOD) || expectPeek(tokenType: .CONSTRUCTOR)

        return Program(cls: cls)
    }

    private func parseFunction() -> Function {
        var function: Function

        if !expectPeek(tokenType: .FUNCTION) && !expectPeek(tokenType: .METHOD) && !expectPeek(tokenType: .CONSTRUCTOR) {
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
            let fnName = Identifier(token: fnNameToken, value: fnNameToken.tokenLiteral, arrayElement: nil)

            if expectPeek(tokenType: .LPARENTHESIS) {
                self.advanceAndSetTokens()
            }
            var parameterList: [Parmeter] = []
            while !expectPeek(tokenType: .RPARENTHESIS) {
                self.advanceAndSetTokens()
                parameterList.append(parseParameter())
            }

            self.advanceAndSetTokens()

            if expectPeek(tokenType: .LBLACE) {
                self.advanceAndSetTokens()
            }

            var varStatements: [VarStatement] = []
            
            while expectPeek(tokenType: .VAR) {
                self.advanceAndSetTokens()
                varStatements.append(parseVarStatement())
            }

            function = Function(token: fnToken!, returnType: returnType!, name: fnName, parameters: parameterList, vars: varStatements, statements: [])
        }

        // Need to repeat at least once.
        repeat {
            if let stmt = self.parseStatements() {
                function.statements.append(stmt)
            } else {
                advanceAndSetTokens()
            }
        } while !expectPeek(tokenType: .FUNCTION) && !expectPeek(tokenType: .METHOD) && !expectPeek(tokenType: .METHOD) && lexer.hasMoreCommands()

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
        let clsName = Identifier(token: clsNameToken, value: clsNameToken.tokenLiteral, arrayElement: nil)

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
//        print(currentToken.tokenType)
        switch currentToken.tokenType {
        case .LET:
            return parseLetStatement()
        case .RETURN:
            return parseReturnStatement()
        case .DO:
            return parseDoStatement()
        case .IF:
            return parseIfStatement()
        case .WHILE:
            return parseWhileStatement()
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
            namesArray.append(Identifier(token: currentToken!, value: currentToken.tokenLiteral, arrayElement: nil))
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

        let letIdent = parseExpression() as? Identifier

        if expectPeek(tokenType: .EQUAL) {
            advanceAndSetTokens()
        }

        advanceAndSetTokens()

        let letExpression = parseExpression()

        if expectPeek(tokenType: .SEMICOLON) {
            advanceAndSetTokens()
        } else {
            unexpectedToken(expectedToken: .SEMICOLON)
        }

        return LetStatement(token: letToken!, name: letIdent!, expression: letExpression!)
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

        let callExp = parseCallExpression()

        if expectPeek(tokenType: .SEMICOLON) {
            advanceAndSetTokens()
        } else {
            unexpectedToken(expectedToken: .SEMICOLON)
        }

        return DoStatement(token: doToken!, callExpression: callExp)
    }
    
    private func parseCallExpression() -> CallExpression {
        let callToken = Token(tokenType: .CALL_EXPRESSION, tokenLiteral: TokenType.CALL_EXPRESSION.rawValue)
        var clsName: Identifier?
        var fnName: Identifier

        if expectPeek(tokenType: .DOT) {
            clsName = Identifier(token: currentToken, value: currentToken.tokenLiteral, arrayElement: nil)
            advanceAndSetTokens()
            if expectPeek(tokenType: .IDENTIFIER) {
                advanceAndSetTokens()
            } else {
                unexpectedToken(expectedToken: .IDENTIFIER)
            }
        }

        fnName = Identifier(token: currentToken, value: currentToken.tokenLiteral, arrayElement: nil)

        if expectPeek(tokenType: .LPARENTHESIS) {
            advanceAndSetTokens()
        }

        var callExp = CallExpression(token: callToken, clsName: clsName, fnName: fnName, arguments: [])
        repeat {
            advanceAndSetTokens()
            if let exp = self.parseExpression() {
                callExp.arguments.append(exp)
            }
        } while !expectPeek(tokenType: .SEMICOLON)

        return callExp
    }

    private func parseParameter() -> Parmeter {
        let parameter = currentToken
        self.advanceAndSetTokens()
        let name = Identifier(token: currentToken!, value: currentToken.tokenLiteral, arrayElement: nil)
        if expectPeek(tokenType: .COMMA) {
            self.advanceAndSetTokens()
        }
        return Parmeter(token: parameter!, name: name)
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
            if !expectPeek(tokenType: .RBLACE) {
                self.advanceAndSetTokens()
            }
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

    private func parseWhileStatement() -> Statement {
        let whileToken = currentToken

        if expectPeek(tokenType: .LPARENTHESIS) {
            self.advanceAndSetTokens()
        }

        advanceAndSetTokens()

        let condition = parseExpression()

        var whileStmt = WhileStatement(token: whileToken!, condition: condition!, consequence: [])

        if expectPeek(tokenType: .RPARENTHESIS) {
            self.advanceAndSetTokens()
        }

        if expectPeek(tokenType: .LBLACE) {
            self.advanceAndSetTokens()
        }

        while !expectPeek(tokenType: .RBLACE) && lexer.hasMoreCommands() {
            if let stmt = self.parseStatements() {
                whileStmt.consequence.append(stmt)
            } else {
                self.advanceAndSetTokens()
            }
        }

        self.advanceAndSetTokens()
        return whileStmt
    }

    private func parseExpression() -> Expression? {
        var expression: Expression
        switch currentToken.tokenType {
        case .TRUE, .FALSE:
            expression = parseBoolean()
        case .THIS, .NULL:
            expression = parseKeywordExpression()
        case .STRING_CONST:
            expression = parseStringLiteral()
        case .INT_CONST:
            expression = parseIntegerLiteral()
        case .IDENTIFIER:
            if expectPeek(tokenType: .DOT) || expectPeek(tokenType: .LBLACE) {
                expression = parseCallExpression()
            } else {
                expression = parseIdentifier()
            }
        default:
            return nil
        }

        if expectPeek(tokenType: .PLUS) || expectPeek(tokenType: .MINUS) || expectPeek(tokenType: .ASTERISK) || expectPeek(tokenType: .SLASH) || expectPeek(tokenType: .LANGLE) || expectPeek(tokenType: .RANGLE) {
            expression = parseInfixExpression(leftExp: expression)
        }
        return expression
    }

    private func parseArrayElement() -> Expression {
        advanceAndSetTokens() // [
        advanceAndSetTokens() // arrayElement
        let arrayElement = parseExpression()
        advanceAndSetTokens() // ]
        return arrayElement!
    }

    private func parseInfixExpression(leftExp: Expression) -> Expression {
        let token = Token(tokenType: .INFIX_EXPRESSION, tokenLiteral: TokenType.INFIX_EXPRESSION.rawValue)
        let left = leftExp
        advanceAndSetTokens()
        let operat = currentToken
        advanceAndSetTokens()
        let rightExp = parseExpression()
        return InfixExpression(token: token, left: left, operat: operat!, right: rightExp!)
    }

    private func parseBoolean() -> Expression {
        return Boolean(token: currentToken, value: Bool(currentToken.tokenLiteral)!)
    }

    private func parseKeywordExpression() -> Expression {
        return KeywordExpression(token: currentToken, value: currentToken.tokenLiteral)
    }

    private func parseIdentifier() -> Expression {
        let token = currentToken!
        var arrayElement: Expression?
        if expectPeek(tokenType: .LBLACKET) {
            arrayElement = parseArrayElement()
        }
        return Identifier(token: token, value: token.tokenLiteral, arrayElement: arrayElement)
    }

    private func parseStringLiteral() -> Expression {
        return StringLiteral(token: currentToken, value: currentToken.tokenLiteral)
    }

    private func parseIntegerLiteral() -> Expression {
        return IntegerLiteral(token: currentToken, value: Int(currentToken.tokenLiteral)!)
    }

    private func unexpectedToken(expectedToken: TokenType) {
        fatalError("nextToken is not expected, expect=\(expectedToken), got=\(nextToken.tokenType)")
    }
}
