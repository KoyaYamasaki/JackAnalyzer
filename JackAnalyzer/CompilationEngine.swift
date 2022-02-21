//
//  CompilationEngine.swift
//  JackAnalyzer
//
//  Created by 山崎宏哉 on 2022/01/10.
//  Copyright © 2022 山崎宏哉. All rights reserved.
//

import Foundation

class CompilationEngine {

    var fileHandle: FileHandle
    var compileList: [String] = []
    var insertOffset = 0
    static var indentIndex = 0
    let program: Program
    var outputStr = ""
    var outputAry: [String] = []

    // Use for only test purposes.
    init(program: Program) {
        self.program = program
        self.fileHandle = FileHandle(forWritingAtPath: "/dev/null")!
    }

    init(outputFileDir: URL, program: Program) {
        FileManager
            .default
            .createFile(
                atPath: outputFileDir.path,
                contents: "".data(using: .utf8),
                attributes: nil)

        print("outputFileDir: \(outputFileDir)")
        self.fileHandle = FileHandle(forWritingAtPath: outputFileDir.path)!
        self.program = program
    }

    func compileProgram() {
        self.compileClass()
    }

    private func keywordTag(_ keyword: String) -> String {
        return "<keyword> \(keyword) </keyword>"
    }

    private func identifierTag(_ identifier: String) -> String {
        return "<identifier> \(identifier) </identifier>"
    }

    private func symbolTag(_ symbol: String) -> String {
        return "<symbol> \(symbol) </symbol>"
    }

    private func stringLiteralTag(_ str: String) -> String {
        return "<stringConstant> \(str) </stringConstant>"
    }

    private func integerLiteralTag(_ integer: Int) -> String {
        return "<integerConstant> \(integer) </integerConstant>"
    }

    private func increaseIndent() {
        Self.indentIndex += 2
    }

    private func decreaseIndent() {
        Self.indentIndex -= 2
    }

    func compileClass() {
        outputAry.shapeAndAppend("<class>")
        increaseIndent() // indent == 1
        outputAry.shapeAndAppend(keywordTag(self.program.cls.token.tokenLiteral))
        outputAry.shapeAndAppend(identifierTag(self.program.cls.name.value))
        outputAry.shapeAndAppend(symbolTag("{"))
        for v in self.program.cls.vars {
            compileClassVarDec(v)
        }
        for subroutine in self.program.cls.functions {
            compileSubroutine(subroutine)
        }
        outputAry.shapeAndAppend(symbolTag("}"))
        decreaseIndent() // indent == 0
        outputAry.shapeAndAppend("</class>")
    }

    func compileClassVarDec(_ v: VarStatement) {
        outputAry.shapeAndAppend("<classVarDec>")
        increaseIndent() // indent == 2
        outputAry.shapeAndAppend(keywordTag(v.token.tokenLiteral))
        if TokenType.keywordSets.contains(v.type.tokenLiteral) {
            outputAry.shapeAndAppend(keywordTag(v.type.tokenLiteral))
        } else {
            outputAry.shapeAndAppend(identifierTag(v.type.tokenLiteral))
        }
        for (index, vName) in v.names.enumerated() {
            outputAry.shapeAndAppend(identifierTag(vName.value))
            if index+1 != v.names.count {
                outputAry.shapeAndAppend(symbolTag(","))
            }
        }
        outputAry.shapeAndAppend(symbolTag(";"))
        decreaseIndent() // indent == 1
        outputAry.shapeAndAppend("</classVarDec>")
    }

    func compileSubroutine(_ subroutine: Function) {
        outputAry.shapeAndAppend("<subroutineDec>")
        increaseIndent() // indent == 2
        outputAry.shapeAndAppend(keywordTag(subroutine.token.tokenLiteral))
        outputAry.shapeAndAppend(keywordTag(subroutine.returnType.tokenLiteral))
        outputAry.shapeAndAppend(identifierTag(subroutine.name.value))
        outputAry.shapeAndAppend(symbolTag("("))
        outputAry.shapeAndAppend("<parameterList>")
        for p in subroutine.parameters {
            compileParameterList(p)
        }
        outputAry.shapeAndAppend("</parameterList>")
        outputAry.shapeAndAppend(symbolTag(")"))
        compileSubroutineBody(varStmts: subroutine.vars, stmts: subroutine.statements)
        decreaseIndent() // indent == 1
        outputAry.shapeAndAppend("</subroutineDec>")
    }

    func compileSubroutineBody(varStmts: [VarStatement], stmts: [Statement]) {
        outputAry.shapeAndAppend("<subroutineBody>")
        increaseIndent() // indent == 3
        outputAry.shapeAndAppend(symbolTag("{"))
        for v in varStmts {
            self.compileVarDec(v)
        }

        outputAry.shapeAndAppend("<statements>")
        increaseIndent() // indent == 4
        for stmt in stmts {
            self.compileStatements(stmt)
        }
        decreaseIndent() // indent == 3
        outputAry.shapeAndAppend("</statements>")
        outputAry.shapeAndAppend(symbolTag("}"))
        decreaseIndent() // indent == 2
        outputAry.shapeAndAppend("</subroutineBody>")
    }

    func compileParameterList(_ p: Token) {
        increaseIndent() // indent == 3
//        outputAry.shapeAndAppend(keywordTag(p.tokenLiteral))
//        for (index, vName) in p.names.enumerated() {
//            outputAry.shapeAndAppend(identifierTag(vName.value))
//            if index+1 != v.names.count {
//                outputAry.shapeAndAppend(symbolTag(","))
//            }
//        }
        decreaseIndent() // indent == 2
    }

    func compileVarDec(_ v: VarStatement) {
        outputAry.shapeAndAppend("<varDec>")
        increaseIndent() // indent == 4
        outputAry.shapeAndAppend(keywordTag(v.token.tokenLiteral))
        if TokenType.keywordSets.contains(v.type.tokenLiteral) {
            outputAry.shapeAndAppend(keywordTag(v.type.tokenLiteral))
        } else {
            outputAry.shapeAndAppend(identifierTag(v.type.tokenLiteral))
        }
        for (index, vName) in v.names.enumerated() {
            outputAry.shapeAndAppend(identifierTag(vName.value))
            if index+1 != v.names.count {
                outputAry.shapeAndAppend(symbolTag(","))
            }
        }
        outputAry.shapeAndAppend(symbolTag(";"))
        decreaseIndent() // indent == 3
        outputAry.shapeAndAppend("</varDec>")
    }

    func compileStatements(_ stmt: Statement) {
        switch stmt.selfTokenType {
        case .LET:
            self.compileLet(stmt as! LetStatement)
        case .DO:
            self.compileDo(stmt as! DoStatement)
        case .IF:
            self.compileIf(stmt as! IfStatement)
        case .WHILE:
            self.compileWhile(stmt as! WhileStatement)
        case .RETURN:
            self.compileReturn(stmt as! ReturnStatement)
        default:
            print("default")
        }
    }

    func compileDo(_ stmt: DoStatement) {
        outputAry.shapeAndAppend("<doStatement>")
        increaseIndent() // indent == 5
        outputAry.shapeAndAppend(self.keywordTag(stmt.token.tokenLiteral))
        if let clsName = stmt.callExpression.clsName {
            outputAry.shapeAndAppend(self.identifierTag(clsName.value))
            outputAry.shapeAndAppend(self.symbolTag("."))
        }
        outputAry.shapeAndAppend(self.identifierTag(stmt.callExpression.fnName.value))
        outputAry.shapeAndAppend(self.symbolTag("("))
        compileExpressionList(stmt.callExpression.arguments)
        outputAry.shapeAndAppend(self.symbolTag(")"))
        outputAry.shapeAndAppend(self.symbolTag(";"))
        decreaseIndent() // indent == 4
        outputAry.shapeAndAppend("</doStatement>")
    }

    func compileLet(_ stmt: LetStatement) {
        outputAry.shapeAndAppend("<letStatement>")
        increaseIndent() // indent == 5
        outputAry.shapeAndAppend(self.keywordTag(stmt.token.tokenLiteral))
        compileNameIdentifier(stmt.name)
        outputAry.shapeAndAppend(self.symbolTag("="))
        outputAry.shapeAndAppend("<expression>")
        compileExpression(stmt.expression)
        outputAry.shapeAndAppend("</expression>")
        outputAry.shapeAndAppend(self.symbolTag(";"))
        decreaseIndent() // indent == 4
        outputAry.shapeAndAppend("</letStatement>")
    }

    func compileWhile(_ stmt: WhileStatement) {
        outputAry.shapeAndAppend("<whileStatement>")
        increaseIndent() // indent == 5
        outputAry.shapeAndAppend(self.keywordTag(stmt.token.tokenLiteral))
        outputAry.shapeAndAppend(self.symbolTag("("))
        outputAry.shapeAndAppend("<expression>")
        compileExpression(stmt.condition)
        outputAry.shapeAndAppend("</expression>")
        outputAry.shapeAndAppend(self.symbolTag(")"))
        outputAry.shapeAndAppend(self.symbolTag("{"))
        outputAry.shapeAndAppend("<statements>")
        increaseIndent() // indent == 6
        for conseq in stmt.consequence {
            print(conseq.printSelf())
            compileStatements(conseq)
        }
        decreaseIndent() // indent == 5
        outputAry.shapeAndAppend("</statements>")
        outputAry.shapeAndAppend(self.symbolTag("}"))
        decreaseIndent() // indent == 4
        outputAry.shapeAndAppend("</whileStatement>")
    }

    func compileReturn(_ stmt: ReturnStatement) {
        outputAry.shapeAndAppend("<returnStatement>")
        increaseIndent() // indent == 5
        outputAry.shapeAndAppend(self.keywordTag(stmt.token.tokenLiteral))
        if let exp = stmt.expression {
            outputAry.shapeAndAppend("<expression>")
            compileExpression(exp)
            outputAry.shapeAndAppend("</expression>")
        }
        outputAry.shapeAndAppend(self.symbolTag(";"))
        decreaseIndent() // indent == 4
        outputAry.shapeAndAppend("</returnStatement>")
    }

    func compileIf(_ stmt: IfStatement) {
        outputAry.shapeAndAppend("<ifStatement>")
        increaseIndent() // indent == 5
        outputAry.shapeAndAppend(self.keywordTag(stmt.token.tokenLiteral))
        outputAry.shapeAndAppend(self.symbolTag("("))
        outputAry.shapeAndAppend("<expression>")
        compileExpression(stmt.condition)
        outputAry.shapeAndAppend("</expression>")
        outputAry.shapeAndAppend(self.symbolTag(")"))
        outputAry.shapeAndAppend(self.symbolTag("{"))
        outputAry.shapeAndAppend("<statements>")
        for stmt in stmt.consequence {
            compileStatements(stmt)
        }
        outputAry.shapeAndAppend("</statements>")
        outputAry.shapeAndAppend(self.symbolTag("}"))
        if let alter = stmt.alternative {
            outputAry.shapeAndAppend(self.keywordTag("else"))
            outputAry.shapeAndAppend(self.symbolTag("{"))
            outputAry.shapeAndAppend("<statements>")
            for stmt in alter {
                compileStatements(stmt)
            }
            outputAry.shapeAndAppend("</statements>")
            outputAry.shapeAndAppend(self.symbolTag("}"))
        }
        decreaseIndent() // indent == 4
        outputAry.shapeAndAppend("</ifStatement>")
    }

    func compileExpression(_ expression: Expression) {
        switch expression.selfTokenType {
        case .BOOLEAN:
            let boolExp = expression as! Boolean
            compileTerm(keywordTag(boolExp.printSelf()))
        case .IDENTIFIER:
            let identExp = expression as! Identifier
            compileIdentifierExpression(identExp)
        case .CALL_EXPRESSION:
            let callExp = expression as! CallExpression
            compileCallExpression(callExp)
        case .STRING_CONST:
            let strExp = expression as! StringLiteral
            compileTerm(stringLiteralTag(strExp.value))
        case .INT_CONST:
            let intExp = expression as! IntegerLiteral
            compileTerm(integerLiteralTag(intExp.value))
        case .INFIX_EXPRESSION:
            let infixExp = expression as! InfixExpression
            compileInfixExpression(infixExp)
        default:
            print("default")
        }
    }

    func compileTerm(_ element: String) {
        increaseIndent() // indent == 6
        outputAry.shapeAndAppend("<term>")
        increaseIndent() // indent == 7
        outputAry.shapeAndAppend(element)
        decreaseIndent() // indent == 6
        outputAry.shapeAndAppend("</term>")
        decreaseIndent() // indent == 5
    }

    func compileIdentifierExpression(_ ident: Identifier) {
        increaseIndent() // indent == 6
        outputAry.shapeAndAppend("<term>")
        increaseIndent() // indent == 7
        compileNameIdentifier(ident)
        decreaseIndent() // indent == 6
        outputAry.shapeAndAppend("</term>")
        decreaseIndent() // indent == 5
    }

    func compileNameIdentifier(_ identifier: Identifier) {
        outputAry.shapeAndAppend(self.identifierTag(identifier.value))
        if let arrayElement = identifier.arrayElement {
            outputAry.shapeAndAppend(self.symbolTag("["))
            outputAry.shapeAndAppend("<expression>")
            compileTerm(self.identifierTag(arrayElement.printSelf()))
            outputAry.shapeAndAppend("</expression>")
            outputAry.shapeAndAppend(self.symbolTag("]"))
        }
    }

    func compileCallExpression(_ callExp: CallExpression) {
        increaseIndent() // indent == 6
        outputAry.shapeAndAppend("<term>")
        increaseIndent() // indent == 7
        if let clsName = callExp.clsName {
            outputAry.shapeAndAppend(self.identifierTag(clsName.value))
            outputAry.shapeAndAppend(self.symbolTag("."))
        }
        outputAry.shapeAndAppend(self.identifierTag(callExp.fnName.value))
        outputAry.shapeAndAppend(self.symbolTag("("))
        compileExpressionList(callExp.arguments)
        outputAry.shapeAndAppend(self.symbolTag(")"))
        decreaseIndent() // indent == 6
        outputAry.shapeAndAppend("</term>")
        decreaseIndent() // indent == 5
    }

    func compileInfixExpression(_ infixExp: InfixExpression) {
        compileExpression(infixExp.left)
        increaseIndent() // indent == 7
        outputAry.shapeAndAppend(self.symbolTag(infixExp.operat.getEscapeCharacters))
        decreaseIndent() // indent == 6
        compileExpression(infixExp.right)
    }

    func compileExpressionList(_ args: [Expression]) {
        outputAry.shapeAndAppend("<expressionList>")
        for (index, arg) in args.enumerated() {
            increaseIndent() // indent == 6
            outputAry.shapeAndAppend("<expression>")
            compileExpression(arg)
            outputAry.shapeAndAppend("</expression>")
            decreaseIndent() // indent == 5
            if index + 1 != args.count {
                outputAry.shapeAndAppend(self.symbolTag(","))
            }
        }
        outputAry.shapeAndAppend("</expressionList>")
    }

    func outPutToXml() {
        for tag in outputAry {
            self.fileHandle.write(tag.data(using: .utf8)!)
            self.fileHandle.write("\n".data(using: .utf8)!)
        }
    }
}
