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

struct LetStatement: Statement {
    let token: Token
    let name: Identifier
    let expression: Expression

    func printSelf() -> String {
        return token.tokenLiteral + " " + name.value + " = " + expression.printSelf()
    }
}

struct ReturnStatement {
    let token: Token
    let expression: Expression
}

struct Identifier {
    let token: Token
    let value: String
}
