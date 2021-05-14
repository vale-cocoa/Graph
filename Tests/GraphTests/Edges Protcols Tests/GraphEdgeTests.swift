//
//  GraphEdgeTests.swift
//  GraphTests
//
//  Created by Valeriano Della Longa on 2021/04/30.
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

final class GraphEdgeTests: XCTestCase {
    var sut: DummyGraphEdge!
    
    override func setUp() {
        super.setUp()
        
        let vertices = givenTwoRandomAndDistinctVertices
        sut = DummyGraphEdge(v: vertices.v, w: vertices.w)
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    func testTail() {
        XCTAssertEqual(sut.tail, sut.either)
    }
    
    func testHead() {
        XCTAssertEqual(sut.head, sut.other(sut.tail))
    }
    
    func testIsSelfLoop() {
        XCTAssertNotEqual(sut.tail, sut.head)
        XCTAssertFalse(sut.isSelfLoop)
        
        let randomVertex = Int.random(in: 0..<20)
        sut = DummyGraphEdge(v: randomVertex, w: randomVertex)
        XCTAssertEqual(sut.tail, sut.head)
        XCTAssertTrue(sut.isSelfLoop)
    }
    
    func testEquatable() {
        var rhs = DummyGraphEdge(v: sut.tail, w: sut.head)
        XCTAssertEqual(sut.either, rhs.either)
        XCTAssertEqual(sut.other(sut.either), rhs.other(rhs.either))
        XCTAssertEqual(sut, rhs)
        
        rhs = DummyGraphEdge(v: sut.tail, w: sut.head + 2)
        XCTAssertNotEqual(sut.other(sut.either), rhs.other(rhs.either))
        XCTAssertNotEqual(sut, rhs)
        
        rhs = DummyGraphEdge(v: sut.tail + 2, w: sut.head)
        XCTAssertNotEqual(sut.either, rhs.either)
        XCTAssertNotEqual(sut, rhs)
    }
    
    func testHashable() {
        var set = Set<DummyGraphEdge>()
        var other = DummyGraphEdge(v: sut.tail, w: sut.head)
        XCTAssertEqual(sut, other)
        set.insert(sut)
        XCTAssertFalse(set.insert(other).inserted)
        XCTAssertEqual(set.count, 1)
        
        other = DummyGraphEdge(v: sut.tail + 2, w: sut.head + 2)
        XCTAssertNotEqual(sut, other)
        set.insert(sut)
        XCTAssertTrue(set.insert(other).inserted)
        XCTAssertEqual(set.count, 2)
    }
    
    func testUndirectedComparator() {
        var rhs = DummyGraphEdge(v: sut.tail, w: sut.head)
        XCTAssertEqual(sut, rhs)
        XCTAssertTrue(sut <~> rhs)
        
        rhs = sut.reversed()
        XCTAssertNotEqual(sut, rhs)
        XCTAssertTrue(sut <~> rhs)
        
        rhs = DummyGraphEdge(v: sut.head + 2, w: sut.tail)
        XCTAssertNotEqual(sut, rhs)
        XCTAssertFalse(sut <~> rhs)
        
        rhs = DummyGraphEdge(v: sut.head, w: sut.tail + 2)
        XCTAssertNotEqual(sut, rhs)
        XCTAssertFalse(sut <~> rhs)
        
        rhs = DummyGraphEdge(v: sut.tail + 2, w: sut.head + 2)
        XCTAssertNotEqual(sut, rhs)
        XCTAssertFalse(sut <~> rhs)
    }
    
}


