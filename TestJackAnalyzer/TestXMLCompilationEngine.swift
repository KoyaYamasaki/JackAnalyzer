//
//  TestXMLCompilationEngine.swift
//  TestJackAnalyzer
//
//  Created by 山崎宏哉 on 2022/02/20.
//  Copyright © 2022 山崎宏哉. All rights reserved.
//

import XCTest
@testable import TestBridgingTarget

class TestXMLCompilationEngine: XCTestCase {

    override func setUpWithError() throws {

    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test01() throws {
        execTest(resource: "ExpressionLessSquare_Main")
    }

    func test02() throws {
        execTest(resource: "ArrayTest")
    }

    func test03() throws {
        execTest(resource: "ExpressionLessSquare_Square")
    }

    func test04() throws {
        execTest(resource: "ExpressionLessSquare_SquareGame")
    }

    func test05() throws {
        execTest(resource: "Square_Main")
    }

    func test06() throws {
        execTest(resource: "Square_Square")
    }

    func test07() throws {
        execTest(resource: "Square_SquareGame")
    }

    func execTest(resource: String) {
        guard let testProgram = Bundle.main.url(forResource: resource, withExtension: "jack") else {
            XCTAssert(false, "Failed to import test program file.")
            return
        }

        guard let testXml = Bundle.main.url(forResource: resource, withExtension: "xml") else {
            XCTAssert(false, "Failed to import test xml file.")
            return
        }

        guard let testXmlContents = try? String(contentsOf: testXml) else {
            XCTAssert(false, "File could not be read.")
            return
        }

        let commandByLine = testXmlContents.components(separatedBy: "\n")
        let lexer = Lexer(fileURL: testProgram)
        let parser = Parser(lexer: lexer)
        let program = parser.startParse()
        let xmlCompEngine = XMLCompilationEngine(program: program)
        xmlCompEngine.compileProgram()

        for i in 0..<xmlCompEngine.outputAry.count {
            XCTAssertEqual(xmlCompEngine.outputAry[i], commandByLine[i])
        }
    }
}
