//
//  TestBridgingTargetTests.swift
//  TestBridgingTargetTests
//
//  Created by 山崎宏哉 on 2022/02/06.
//  Copyright © 2022 山崎宏哉. All rights reserved.
//

import XCTest
@testable import TestBridgingTarget

class TestJackTokenizer: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test01() throws {
        var index = 0
        let correctArray = ["let", "a", "=", "10", ";"]
        let testToken = JackTokenizer(contentStr: "let a = 10;")

        while testToken.hasMoreCommands() {
            testToken.advance()
            XCTAssertEqual(testToken.currentToken, correctArray[index])
            index += 1
        }
    }

    func test02() throws {
        var index = 0
        let testStr =
        """
            class Main {
                function void printHello() {
                    do Output.printString("Hello World");
                }
            }
        """
        let correctArray = ["class", "Main", "{", "function", "void", "printHello", "(", ")", "{", "do", "Output", ".", "printString", "(", "\"Hello World\"", ")", ";", "}", "}"]
        let testToken = JackTokenizer(contentStr: testStr)

        while testToken.hasMoreCommands() {
            testToken.advance()
            XCTAssertEqual(testToken.currentToken, correctArray[index])
            index += 1
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
