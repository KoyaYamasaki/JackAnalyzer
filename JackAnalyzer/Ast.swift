//
//  Ast.swift
//  JackAnalyzer
//
//  Created by 山崎宏哉 on 2022/01/22.
//  Copyright © 2022 山崎宏哉. All rights reserved.
//

import Foundation

let indent = 4

protocol Node {
    func printSelf() -> String
}

protocol Statement: Node {
    var selfTokenType: TokenType { get }
}

protocol Expression: Node {
    var selfTokenType: TokenType { get }
}

struct Program {
    var cls: Class
}

struct Class: Node {
    let token: Token
    let name: Identifier
    var vars: [VarStatement]
    var functions: [Function]

    func printSelf() -> String {
        var fnStr = ""
        for fn in functions {
            fnStr += "\(fn.printSelf())\n"
        }
        var fnArray = fnStr.components(separatedBy: "\n")
        fnArray = fnArray.map {
            if !$0.isEmpty {
                return "\($0.indent(indent))"
            }
            return ""
        }

        var varStr = ""
        for v in vars {
            varStr += "\(v.printSelf().indent(indent))\n"
        }
        return token.tokenLiteral + " " + name.value + " " + "{\n" + varStr + fnArray.joined(separator: "\n") + "}"
    }

    static func makeProvisionalClass() -> Class {
        let clsToken = Token(tokenType: .CLASS, tokenLiteral: "class")

        let clsNameToken = Token(tokenType: .IDENTIFIER, tokenLiteral: "Main")

        let clsName = Identifier(token: clsNameToken, value: clsNameToken.tokenLiteral, arrayElement: nil)

        return Class(token: clsToken, name: clsName, vars: [], functions: [])
    }
}

struct Function: Node {
    let token: Token
    let returnType: Token
    let name: Identifier
    var parameters: [Parameter]
    var vars: [VarStatement]
    var statements: [Statement]

    func printSelf() -> String {
        var stmtStr = ""
        for stmt in statements {
            stmtStr += "\(stmt.printSelf().indent(indent))\n"
        }

        var varStr = ""
        for v in vars {
            varStr += "\(v.printSelf().indent(indent))\n"
        }
        return token.tokenLiteral + " " + returnType.tokenLiteral + " " + name.value + "()" + " {\n" + varStr + stmtStr + "}"
    }

    static func makeProvisionalFunction() -> Function {
        let fnToken = Token(tokenType: .FUNCTION, tokenLiteral: "function")
        let returnType = Token(tokenType: .VOID, tokenLiteral: "void")
        let fnNameToken = Token(tokenType: .IDENTIFIER, tokenLiteral: "main")
        let fnName = Identifier(token: fnNameToken, value: fnNameToken.tokenLiteral, arrayElement: nil)

        return Function(token: fnToken, returnType: returnType, name: fnName, parameters: [], vars: [], statements: [])
    }
}

struct VarStatement: Statement {
    let token: Token
    let type: Token
    let names: [Identifier]

    func printSelf() -> String {
        var namesStr = ""
        for name in names {
            namesStr += "\(name.value), "
        }
        if !namesStr.isEmpty { namesStr.removeLast(2) }

        return token.tokenLiteral + " " + type.tokenLiteral + " " + namesStr + ";"
    }

    var selfTokenType: TokenType {
        return token.tokenType
    }
}

struct LetStatement: Statement {
    let token: Token
    let name: Identifier
    let expression: Expression

    func printSelf() -> String {
        return token.tokenLiteral + " " + name.value + " = " + expression.printSelf() + ";"
    }

    var selfTokenType: TokenType {
        return token.tokenType
    }
}

struct ReturnStatement: Statement {
    let token: Token
    let expression: Expression?

    func printSelf() -> String {
        if let exp = expression {
            return token.tokenLiteral + " " + exp.printSelf() + ";"
        } else {
            return token.tokenLiteral + ";"
        }
    }

    var selfTokenType: TokenType {
        return token.tokenType
    }
}

struct DoStatement: Statement {
    let token: Token
    let callExpression: CallExpression

    func printSelf() -> String {
        var argStr = ""
        for arg in callExpression.arguments {
            argStr += "\(arg.printSelf()), "
        }
        if !argStr.isEmpty { argStr.removeLast(2) }

        if let cName = callExpression.clsName {
            return token.tokenLiteral + " " + cName.value + "." + callExpression.fnName.value + "(\(argStr));"
        } else {
            return token.tokenLiteral + " " + callExpression.fnName.value + "(\(argStr));"
        }
    }

    var selfTokenType: TokenType {
        return token.tokenType
    }
}

struct IfStatement: Statement {
    let token: Token
    let condition: Expression
    var consequence: [Statement]
    var alternative: [Statement]?

    func printSelf() -> String {
        var conseqStr = ""
        for conseq in consequence {
            conseqStr += "\(conseq.printSelf().indent(indent))\n"
        }

        if let alternative = alternative {
            var alterStr = ""
            for alter in alternative {
                alterStr += "\(alter.printSelf().indent(indent))\n"
            }
            return token.tokenLiteral + " " + "(" + condition.printSelf() + ")" + " " + "{\n" + conseqStr + "}\n".indent(indent) + "else ".indent(indent) + "{\n" + alterStr + "}"
        } else {
            return token.tokenLiteral + " " + "(" + condition.printSelf() + ")" + " " + "{\n" + conseqStr + "}"
        }
    }

    var selfTokenType: TokenType {
        return token.tokenType
    }
}

struct WhileStatement: Statement {
    let token: Token
    let condition: Expression
    var consequence: [Statement]

    var selfTokenType: TokenType {
        return token.tokenType
    }
    
    func printSelf() -> String {
        var conseqStr = ""
        for conseq in consequence {
            conseqStr += "\(conseq.printSelf().indent(indent))\n"
        }

        return token.tokenLiteral + " (" + condition.printSelf() + ") " + "{\n" + conseqStr + "}"
    }
}

struct CallExpression: Expression {
    let token: Token
    var clsName: Identifier?
    let fnName: Identifier
    var arguments: [Expression]

    var selfTokenType: TokenType {
        return token.tokenType
    }
    
    func printSelf() -> String {
        return ""
    }
}

struct Identifier: Expression {
    let token: Token
    let value: String
    let arrayElement: Expression?

    func printSelf() -> String {
        return value
    }

    var selfTokenType: TokenType {
        return token.tokenType
    }

    var getArrayElement: Identifier? {
        if let arrayElement = arrayElement {
            return arrayElement as? Identifier
        } else {
            return nil
        }
    }
}

struct Boolean: Expression {
    let token: Token
    let value: Bool

    func printSelf() -> String {
        return value.description
    }

    var selfTokenType: TokenType {
        return token.tokenType
    }
}

struct KeywordExpression: Expression {
    let token: Token
    let value: String

    func printSelf() -> String {
        return value
    }

    var selfTokenType: TokenType {
        return token.tokenType
    }
}

struct StringLiteral: Expression {
    let token: Token
    let value: String

    func printSelf() -> String {
        return value
    }

    var selfTokenType: TokenType {
        return token.tokenType
    }
}

struct IntegerLiteral: Expression {
    let token: Token
    let value: Int

    func printSelf() -> String {
        return String(value)
    }

    var selfTokenType: TokenType {
        return token.tokenType
    }
}

struct Parameter: Expression {
    let token: Token
    let name: Identifier

    func printSelf() -> String {
        return token.tokenLiteral + " " + name.value
    }

    var selfTokenType: TokenType {
        return token.tokenType
    }
}

struct PrefixExpression: Expression {
    let token: Token
    let operat: Token
    let right: Expression

    var selfTokenType: TokenType {
        return token.tokenType
    }
    
    func printSelf() -> String {
        var rightStr = right.printSelf()
        if self.isInfix(exp: right) {
            rightStr = "(" + right.printSelf() + ")"
        }

        return operat.tokenLiteral + rightStr
    }

    func isInfix(exp: Expression) -> Bool {
        return (exp as? InfixExpression) != nil
    }
}

struct InfixExpression: Expression {
    let token: Token
    let left: Expression
    let operat: Token
    let right: Expression

    var selfTokenType: TokenType {
        return token.tokenType
    }
    
    func printSelf() -> String {
        var leftStr = left.printSelf()
        if self.isPrefixOrInfix(exp: left) {
            leftStr = "(" + left.printSelf() + ")"
        }

        var rightStr = right.printSelf()
        if self.isPrefixOrInfix(exp: right) {
            rightStr = "(" + right.printSelf() + ")"
        }

        return leftStr + " " + operat.tokenLiteral + " " + rightStr
    }

    func isPrefixOrInfix(exp: Expression) -> Bool {
        return ((exp as? PrefixExpression) != nil) || ((exp as? InfixExpression) != nil)
    }
}
