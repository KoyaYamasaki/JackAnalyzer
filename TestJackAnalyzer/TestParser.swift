//
//  TestParser.swift
//  TestJackAnalyzer
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

    func testLetStatement() throws {
        let testIdent = "letIdentifier"
        let testExpression = "true"
        let testStmt = "let \(testIdent) = \(testExpression);"

        let tokenizer = JackTokenizer(contentStr: testStmt)
        let analyzer = JackAnalyzer(tokenizer: tokenizer, compilationEngine: compEngine)

        let program = analyzer.startParse()
        XCTAssertEqual(program.statements.count, 1)

        let stmt = program.statements[0]

        XCTAssertEqual(stmt.printSelf(), testStmt)

        guard let letStmt = stmt as? LetStatement else {
            XCTAssertThrowsError("Statement is not LET")
            return
        }

        XCTAssertEqual(letStmt.name.token.tokenType, .IDENTIFIER)
        XCTAssertEqual(letStmt.name.value, testIdent)

        XCTAssertEqual(letStmt.expression.printSelf(), testExpression)
    }

    func testReturnStatement() throws {
        let testExpression = "true"
        let testStmt = "return \(testExpression);"

        let tokenizer = JackTokenizer(contentStr: testStmt)
        let analyzer = JackAnalyzer(tokenizer: tokenizer, compilationEngine: compEngine)

        let program = analyzer.startParse()
        XCTAssertEqual(program.statements.count, 1)

        let stmt = program.statements[0]

        XCTAssertEqual(stmt.printSelf(), testStmt)

        guard let returnStmt = stmt as? ReturnStatement else {
            XCTAssertThrowsError("Statement is not Return")
            return
        }

        XCTAssertEqual(returnStmt.token.tokenType, .RETURN)
        XCTAssertEqual(returnStmt.expression.printSelf(), testExpression)
    }
}
