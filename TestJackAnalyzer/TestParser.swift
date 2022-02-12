//
//  TestParser.swift
//  TestParser
//
//  Created by 山崎宏哉 on 2022/02/09.
//  Copyright © 2022 山崎宏哉. All rights reserved.
//

import XCTest
@testable import TestBridgingTarget

class TestParser: XCTestCase {

    let compEngine = CompilationEngine()
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testClass01() throws {
        let testClsName = "TestCls"
        let testCls = "class \(testClsName) { function void main() { return 0; } }"

        let lexer = Lexer(contentStr: testCls)
        let parser = Parser(tokenizer: lexer, compilationEngine: compEngine)
        let program = analyzer.startParse()
        let cls = program.cls

        XCTAssertEqual(cls.printSelf(), testCls)
        XCTAssertEqual(cls.token.tokenType, .CLASS)
        XCTAssertEqual(cls.name.token.tokenType, .IDENTIFIER)
        XCTAssertEqual(cls.name.value, testClsName)
    }

    func testClass02() throws {
        let testCls = "let testNoCls = 10;"
        let expectClsStr = "class Main { function void main() { \(testCls) } }"

        let lexer = Lexer(contentStr: testCls)
        let parser = Parser(tokenizer: tokenizer, compilationEngine: compEngine)
        let program = analyzer.startParse()
        let cls = program.cls

        XCTAssertEqual(cls.printSelf(), expectClsStr)
        XCTAssertEqual(cls.token.tokenType, .CLASS)
        XCTAssertEqual(cls.name.token.tokenType, .IDENTIFIER)
        XCTAssertEqual(cls.name.value, "Main")
    }

    func testFunction01() throws {
        let testFnName = "testFn"
        let returnType = Token(tokenType: .VOID, tokenLiteral: "void")
        let testFn = "function void \(testFnName)() { return 0; }"

        let lexer = Lexer(contentStr: testFn)
        let parser = Parser(tokenizer: tokenizer, compilationEngine: compEngine)
        let program = analyzer.startParse()
        XCTAssertEqual(program.cls.functions.count, 1)

        let fn = program.cls.functions[0]

        XCTAssertEqual(fn.printSelf(), testFn)
        XCTAssertEqual(fn.token.tokenType, .FUNCTION)
        XCTAssertEqual(fn.returnType.tokenType, returnType.tokenType)
        XCTAssertEqual(fn.name.value, testFnName)
    }

    func testFunction02() throws {
        let testfn = "return true;"
        let expectFn = "function void main() { \(testfn) }"

        let lexer = Lexer(contentStr: testfn)
        let parser = Parser(tokenizer: tokenizer, compilationEngine: compEngine)
        let program = analyzer.startParse()
        XCTAssertEqual(program.cls.functions.count, 1)

        let fn = program.cls.functions[0]

        XCTAssertEqual(fn.printSelf(), expectFn)
        XCTAssertEqual(fn.token.tokenType, .FUNCTION)
        XCTAssertEqual(fn.returnType.tokenType, .VOID)
        XCTAssertEqual(fn.name.value, "main")
    }

    func testLetStatement() throws {
        let testCount = 3
        let testIdent = ["letIdentifier", "x", "y"]
        let testExpression = ["true", "15", "x"]

        for i in 0..<testCount {
            let testStmt = "let \(testIdent[i]) = \(testExpression[i]);"

            let lexer = Lexer(contentStr: testStmt)
            let parser = Parser(tokenizer: tokenizer, compilationEngine: compEngine)

            let program = analyzer.startParse()
            XCTAssertEqual(program.cls.functions[0].statements.count, 1)

            let stmt = program.cls.functions[0].statements[0]

            XCTAssertEqual(stmt.printSelf(), testStmt)

            guard let letStmt = stmt as? LetStatement else {
                XCTAssertThrowsError("Statement is not LET")
                return
            }

            XCTAssertEqual(letStmt.name.token.tokenType, .IDENTIFIER)
            XCTAssertEqual(letStmt.name.value, testIdent[i])

            XCTAssertEqual(letStmt.expression.printSelf(), testExpression[i])
        }
    }

    func testReturnStatement() throws {
        let testCount = 4
        let testExpression = ["true", "5", "foobar", ""]


        for i in 0..<testCount {
            var testStmt = ""
            testStmt = testExpression[i] != "" ? "return \(testExpression[i]);" : "return;"

            let lexer = Lexer(contentStr: testStmt)
            let parser = Parser(tokenizer: tokenizer, compilationEngine: compEngine)
            
            let program = analyzer.startParse()
            XCTAssertEqual(program.cls.functions[0].statements.count, 1)
            
            let stmt = program.cls.functions[0].statements[0]
            
            guard let returnStmt = stmt as? ReturnStatement else {
                XCTAssertThrowsError("Statement is not Return")
                return
            }

            XCTAssertEqual(returnStmt.printSelf(), testStmt)

            XCTAssertEqual(returnStmt.token.tokenType, .RETURN)
            if let exp = returnStmt.expression {
                XCTAssertEqual(exp.printSelf(), testExpression[i])
            }
        }
    }
}
