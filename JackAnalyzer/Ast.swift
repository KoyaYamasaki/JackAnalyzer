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

protocol Statement: Node {}
protocol Expression: Node {}

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
        return token.tokenLiteral + " " + name.value + " " + "{\n" + varStr + "\n" + fnArray.joined(separator: "\n") + "}"
    }

    static func makeProvisionalClass() -> Class {
        let clsToken = Token(tokenType: .CLASS, tokenLiteral: "class")

        let clsNameToken = Token(tokenType: .IDENTIFIER, tokenLiteral: "Main")

        let clsName = Identifier(token: clsNameToken, value: clsNameToken.tokenLiteral)

        return Class(token: clsToken, name: clsName, vars: [], functions: [])
    }
}

struct Function: Node {
    let token: Token
    let returnType: Token
    let name: Identifier
    var parameters: [Token]
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
        let fnName = Identifier(token: fnNameToken, value: fnNameToken.tokenLiteral)

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
}

struct LetStatement: Statement {
    let token: Token
    let name: Identifier
    let expression: Expression

    func printSelf() -> String {
        return token.tokenLiteral + " " + name.value + " = " + expression.printSelf() + ";"
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
}

struct DoStatement: Statement {
    let token: Token
    var clsName: Identifier?
    let fnName: Identifier
    var arguments: [Expression]

    func printSelf() -> String {
        var argStr = ""
        for arg in arguments {
            argStr += "\(arg.printSelf()), "
        }
        argStr.removeLast(2)

        if let cName = clsName {
            return token.tokenLiteral + " " + cName.value + "." + fnName.value + "(\(argStr));"
        } else {
            return token.tokenLiteral + " " + fnName.value + "(\(argStr));"
        }
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
            return token.tokenLiteral + " " + "(" + condition.printSelf() + ")" + " " + "{\n" + conseqStr + "}" + " else " + "{\n" + alterStr + "}"
        } else {
            return token.tokenLiteral + " " + "(" + condition.printSelf() + ")" + " " + "{\n" + conseqStr + "}"
        }
    }
}

struct Identifier: Expression {
    let token: Token
    let value: String

    func printSelf() -> String {
        return value
    }
}

struct Boolean: Expression {
    let token: Token
    let value: Bool

    func printSelf() -> String {
        return value.description
    }
}

struct StringLiteral: Expression {
    let token: Token
    let value: String

    func printSelf() -> String {
        return value
    }
}

struct IntegerLiteral: Expression {
    let token: Token
    let value: Int

    func printSelf() -> String {
        return String(value)
    }
}
