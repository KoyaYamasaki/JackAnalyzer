//
//  CompilationEngine.swift
//  JackAnalyzer
//
//  Created by 山崎宏哉 on 2022/01/10.
//  Copyright © 2022 山崎宏哉. All rights reserved.
//

import Foundation

class CompilationEngine {

    var fileHandle: FileHandle!
    var compileList: [String] = []
    var insertOffset = 0
    var indentIndex = 0

    // This is for test purpose.
    init() {}

    init(outputFileDir: URL) {
        FileManager
            .default
            .createFile(
                atPath: outputFileDir.path,
                contents: "".data(using: .utf8),
                attributes: nil)

        print("outputFileDir: \(outputFileDir)")
        fileHandle = FileHandle(forWritingAtPath: outputFileDir.path)!
    }

    func addToCompileTokenList(token: String) {
        compileList.insert(token.indent(indentIndex), at: compileList.count-insertOffset)
    }

    func compileClass() {
        compileList.insert("<class>", at: compileList.count-insertOffset)
        compileList.insert("</class>", at: compileList.count-insertOffset)
        insertOffset += 1
        indentIndex += 2
    }

    func compileClassVarDec() {
        
    }

    func compileSubroutine() {
        compileList.insert("<subroutineDec>".indent(indentIndex), at: compileList.count-insertOffset)
        compileList.insert("</subroutineDec>".indent(indentIndex), at: compileList.count-insertOffset)
        insertOffset += 1
        indentIndex += 2
    }

    func compileSubroutineBody() {
        compileList.insert("<subroutineBody>".indent(indentIndex), at: compileList.count-insertOffset)
        compileList.insert("</subroutineBody>".indent(indentIndex), at: compileList.count-insertOffset)
        insertOffset += 1
        indentIndex += 2
    }

    func compileParameterList() {
        compileList.insert("<parameterList>".indent(indentIndex), at: compileList.count-insertOffset)
        compileList.insert("</parameterList>".indent(indentIndex), at: compileList.count-insertOffset)
    }

    func compileVarDec() {
        compileList.insert("<varDec>".indent(indentIndex), at: compileList.count-insertOffset)
        compileList.insert("</varDec>".indent(indentIndex), at: compileList.count-insertOffset)
        insertOffset += 1
        indentIndex += 2
    }

    func compileStatements() {
        compileList.insert("<statements>".indent(indentIndex), at: compileList.count-insertOffset)
        compileList.insert("</statements>".indent(indentIndex), at: compileList.count-insertOffset)
        insertOffset += 1
        indentIndex += 2
    }

    func compileDo() {
        compileList.insert("<doStatement>".indent(indentIndex), at: compileList.count-insertOffset)
        compileList.insert("</doStatement>".indent(indentIndex), at: compileList.count-insertOffset)
        insertOffset += 1
        indentIndex += 2
    }

    func compileLet() {
        compileList.insert("<letStatement>".indent(indentIndex), at: compileList.count-insertOffset)
        compileList.insert("</letStatement>".indent(indentIndex), at: compileList.count-insertOffset)
        insertOffset += 1
        indentIndex += 2
    }

    func compileWhile() {
        compileList.insert("<whileStatement>".indent(indentIndex), at: compileList.count-insertOffset)
        compileList.insert("</whileStatement>".indent(indentIndex), at: compileList.count-insertOffset)
        insertOffset += 1
        indentIndex += 2
    }

    func compileReturn() {
        compileList.insert("<returnStatement>".indent(indentIndex), at: compileList.count-insertOffset)
        compileList.insert("</returnStatement>".indent(indentIndex), at: compileList.count-insertOffset)
        insertOffset += 1
        indentIndex += 2
    }

    func compileIf() {
        compileList.insert("<ifStatement>".indent(indentIndex), at: compileList.count-insertOffset)
        compileList.insert("</ifStatement>".indent(indentIndex), at: compileList.count-insertOffset)
        insertOffset += 1
        indentIndex += 2
    }

    func compileExpression() {
        compileList.insert("<expression>".indent(indentIndex), at: compileList.count-insertOffset)
        compileList.insert("</expression>".indent(indentIndex), at: compileList.count-insertOffset)
        insertOffset += 1
        indentIndex += 2
    }

    func compileTerm(additionalOffset: Int = 0) {
        compileList.insert("<term>".indent(indentIndex), at: compileList.count-insertOffset-additionalOffset)
        compileList.insert("</term>".indent(indentIndex), at: compileList.count-insertOffset)
        insertOffset += 1
        indentIndex += 2
    }

    func compileExpressionList() {
        compileList.insert("<expressionList>".indent(indentIndex), at: compileList.count-insertOffset)
        compileList.insert("</expressionList>".indent(indentIndex), at: compileList.count-insertOffset)
        insertOffset += 1
        indentIndex += 2
    }

    func endCurrentTag() {
        insertOffset -= 1
        indentIndex -= 2
    }

    func endCurrentTagBy(_ additionalOffset: Int = 1) {
        print("insertOffset: ", insertOffset)
        print("indentIndex: ", indentIndex)
        insertOffset -= 1 * additionalOffset
        indentIndex -= 2 * additionalOffset
    }

    func outPutToXml() {
        for token in compileList {
            self.fileHandle.write(token.data(using: .utf8)!)
            self.fileHandle.write("\n".data(using: .utf8)!)
        }
    }
}
