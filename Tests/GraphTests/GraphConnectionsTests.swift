//
//  GraphConnectionsTests.swift
//  GraphTests
//
//  Created by Valeriano Della Longa on 2021/05/08.
//  Copyright © 2021 Valeriano Della Longa
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, merge,
//  publish, distribute, sublicense, and/or sell copies of the Software,
//  and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included
//  in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
//  FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import XCTest
@testable import Graph

final class GraphConnectionsTests: XCTestCase {
    func testDirected() {
        let sut = GraphConnections.directed
        XCTAssertEqual(sut, GraphConnections.directed)
    }
    
    func testUndirected() {
        let sut = GraphConnections.undirected
        XCTAssertEqual(sut, GraphConnections.undirected)
    }
    
    func testAllCases() {
        let expectedResult: Set<GraphConnections> = [.directed, .undirected]
        let allCases = Set(GraphConnections.allCases)
        XCTAssertEqual(expectedResult, allCases)
    }
    
    func testEncodeThanDecode() {
        var sut: GraphConnections = .directed
        var data: Data? = nil
        XCTAssertNoThrow(try data = JSONEncoder().encode(sut))
        if let encoded = data {
            var decoded: GraphConnections? = nil
            XCTAssertNoThrow(try decoded = JSONDecoder().decode(GraphConnections.self, from: encoded))
            XCTAssertEqual(decoded, sut)
        }
        
        sut = .undirected
        data = nil
        XCTAssertNoThrow(try data = JSONEncoder().encode(sut))
        if let encoded = data {
            var decoded: GraphConnections? = nil
            XCTAssertNoThrow(try decoded = JSONDecoder().decode(GraphConnections.self, from: encoded))
            XCTAssertEqual(decoded, sut)
        }
    }
    
}
