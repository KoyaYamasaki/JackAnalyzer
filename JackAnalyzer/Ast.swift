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
    let token: Token<Keyword>
    let name: Identifier
    let expression: Expression

    func printSelf() -> String {
        return token.tokenLiteral.literal() + " " + name.value + " = " + expression.printSelf()
    }
}

struct ReturnStatement {
    let token: Token<Keyword>
    let expression: Expression
}

struct Identifier {
    let token: Token<String>
    let value: String
}
