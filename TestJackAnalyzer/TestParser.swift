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
        let testCount = 3
        let testIdent = ["letIdentifier", "x", "y"]
        let testExpression = ["true", "15", "x"]

        for i in 0..<testCount {
            let testStmt = "let \(testIdent[i]) = \(testExpression[i]);"

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

            let tokenizer = JackTokenizer(contentStr: testStmt)
            let analyzer = JackAnalyzer(tokenizer: tokenizer, compilationEngine: compEngine)
            
            let program = analyzer.startParse()
            XCTAssertEqual(program.statements.count, 1)
            
            let stmt = program.statements[0]
            
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
