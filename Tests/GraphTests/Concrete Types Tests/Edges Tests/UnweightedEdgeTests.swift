//
//  UnweightedEdgeTests.swift
//  GraphTests
//
//  Created by Valeriano Della Longa on 2021/04/15.
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

final class UnweightedEdgeTests: XCTestCase {
    var sut: UnweightedEdge!
    
    override func setUp() {
        super.setUp()
        
        sut = UnweightedEdge(vertices: givenTwoRandomAndDistinctVertices)
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    func testInitVertices() {
        let vertices = givenTwoRandomAndDistinctVertices
        sut = UnweightedEdge(vertices: vertices)
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.v, vertices.0)
        XCTAssertEqual(sut.w, vertices.1)
    }
    
    func testInitTailHead() {
        let vertices = givenTwoRandomAndDistinctVertices
        sut = UnweightedEdge(tail: vertices.0, head: vertices.1)
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.v, vertices.0)
        XCTAssertEqual(sut.w, vertices.1)
    }
    
    func testEither() {
        XCTAssertEqual(sut.either, sut.v)
    }
    
    func testOther() {
        XCTAssertEqual(sut.other(sut.v), sut.w)
        XCTAssertEqual(sut.other(sut.w), sut.v)
    }
    
    func testReversed() {
        let reversed = sut.reversed()
        XCTAssertEqual(reversed.v, sut.w)
        XCTAssertEqual(reversed.w, sut.v)
    }
    
    func testsCodable() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        do {
            let data = try encoder.encode(sut)
            do {
                let decoded = try decoder.decode(UnweightedEdge.self, from: data)
                XCTAssertEqual(decoded, sut)
            } catch {
                XCTFail("Thrown error while decoding.")
            }
        } catch {
            XCTFail("Thrown error while encoding.")
        }
    }
    
}
