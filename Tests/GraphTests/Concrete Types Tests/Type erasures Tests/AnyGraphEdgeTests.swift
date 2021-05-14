//
//  AnyGraphEdgeTests.swift
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

final class AnyGraphEdgeTests: XCTestCase {
    var sut: AnyGraphEdge!
    
    override func setUp() {
        super.setUp()
        
        sut = AnyGraphEdge(tail: Int.random(in: 0..<10), head: Int.random(in: 10..<20))
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    func testInitFromVertices() {
        let vertices = givenTwoRandomAndDistinctVertices
        sut = AnyGraphEdge(vertices: vertices)
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.either, vertices.0)
        XCTAssertEqual(sut.other(sut.either), vertices.1)
        XCTAssertEqual(sut.other(vertices.1), vertices.0)
        let swapped = (vertices.1, vertices.0)
        let expectedResult = AnyGraphEdge(vertices: swapped)
        XCTAssertEqual(sut.reversed(), expectedResult)
    }
    
    func testInitWithTailAndHead() {
        let vertices = givenTwoRandomAndDistinctVertices
        let tail = vertices.v
        let head = vertices.w
        sut = AnyGraphEdge(tail: tail, head: head)
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.tail, tail)
        XCTAssertEqual(sut.head, head)
        XCTAssertEqual(sut.either, tail)
        XCTAssertEqual(sut.other(tail), head)
        XCTAssertEqual(sut.other(head), tail)
        XCTAssertEqual(sut.reversed(), AnyGraphEdge(tail: head, head: tail))
    }
    
    func testInitFromConcrete() {
        let vertices = givenTwoRandomAndDistinctVertices
        let concrete = DummyGraphEdge(v: vertices.v, w: vertices.w)
        sut = AnyGraphEdge(concrete)
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.either, vertices.v)
        XCTAssertEqual(sut.either, concrete.either)
        XCTAssertEqual(sut.other(vertices.v), vertices.w)
        XCTAssertEqual(sut.other(vertices.v), concrete.other(vertices.v))
        XCTAssertEqual(sut.other(vertices.w), sut.either)
        XCTAssertEqual(sut.other(vertices.w), concrete.other(vertices.w))
        let concreteReversed = concrete.reversed()
        let sutReversed = sut.reversed()
        XCTAssertEqual(sutReversed, AnyGraphEdge(concreteReversed))
    }
    
    func testWhenConcreteIsAnyWeightedGraphEdge() {
        let vertices = givenTwoRandomAndDistinctVertices
        let wEdgeDouble = AnyWeightedGraphEdge(tail: vertices.v, head: vertices.w, weight: 10.0)
        let wEdgeInt = AnyWeightedGraphEdge(tail: vertices.v, head: vertices.w, weight: 10)
        
        sut = AnyGraphEdge(wEdgeDouble)
        XCTAssertNotNil(sut)
        
        let other = AnyGraphEdge(wEdgeInt)
        XCTAssertNotNil(other)
        
        XCTAssertEqual(sut, other)
    }
    
}


