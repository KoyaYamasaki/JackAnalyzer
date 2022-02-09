//
//  Ast.swift
//  JackAnalyzer
//
//  Created by 山崎宏哉 on 2022/01/22.
//  Copyright © 2022 山崎宏哉. All rights reserved.
//

import Foundation

protocol Node {
    func printSelf() -> String
}

protocol Statement: Node {}
protocol Expression: Node {}

struct Program {
    var statements: [Statement]
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
    let expression: Expression

    func printSelf() -> String {
        return token.tokenLiteral + " " + expression.printSelf() + ";"
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
