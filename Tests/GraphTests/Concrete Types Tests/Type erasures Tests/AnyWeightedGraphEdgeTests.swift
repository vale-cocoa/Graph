//
//  AnyWeightedGraphEdgeTests.swift
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

final class AnyWeightedGraphEdgeTests: XCTestCase {
    var sut: AnyWeightedGraphEdge<Double>!
    
    override func setUp() {
        super.setUp()
        
        let vertices = givenTwoRandomAndDistinctVertices
        sut = AnyWeightedGraphEdge(tail: vertices.v, head: vertices.w, weight: Double.random(in: 0..<10.0))
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    func testInitFromVerticesAndWeight() {
        let vertices = givenTwoRandomAndDistinctVertices
        let randomWeight = Double.random(in: 0..<10.0)
        
        sut = AnyWeightedGraphEdge(vertices: vertices, weight: randomWeight)
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.either, vertices.v)
        XCTAssertEqual(sut.other(vertices.v), vertices.w)
        XCTAssertEqual(sut.other(vertices.w), vertices.v)
        XCTAssertEqual(sut.weight, randomWeight)
        
        var reversed = sut.reversed()
        XCTAssertTrue(sut <~> reversed)
        XCTAssertTrue(sut <=~=> reversed)
        
        let newWeight = randomWeight + 0.50
        reversed = sut.reversedWith(weight: newWeight)
        XCTAssertTrue(sut <~> reversed)
        XCTAssertFalse(sut <=~=> reversed)
    }
    
    func testInitFromTailHeadAndWeight() {
        let vertices = givenTwoRandomAndDistinctVertices
        let randomWeight = Double.random(in: 0..<10.0)
        
        sut = AnyWeightedGraphEdge(tail: vertices.v, head: vertices.w, weight: randomWeight)
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.either, vertices.v)
        XCTAssertEqual(sut.other(vertices.v), vertices.w)
        XCTAssertEqual(sut.other(vertices.w), vertices.v)
        XCTAssertEqual(sut.weight, randomWeight)
        XCTAssertEqual(sut.tail, vertices.v)
        XCTAssertEqual(sut.head, vertices.w)
        
        var reversed = sut.reversed()
        XCTAssertTrue(sut <~> reversed)
        XCTAssertTrue(sut <=~=> reversed)
        
        let newWeight = randomWeight + 0.50
        reversed = sut.reversedWith(weight: newWeight)
        XCTAssertTrue(sut <~> reversed)
        XCTAssertFalse(sut <=~=> reversed)
    }
    
    func testInitFromConcrete() {
        let vertices = givenTwoRandomAndDistinctVertices
        let randomWeight = Double.random(in: 0..<10.0)
        let concrete = DummyWeightedGraphEdge(v: vertices.v, w: vertices.w, weight: randomWeight)
        sut = AnyWeightedGraphEdge(concrete)
        XCTAssertEqual(sut.either, concrete.either)
        XCTAssertEqual(sut.other(vertices.v), concrete.other(vertices.v))
        XCTAssertEqual(sut.other(vertices.w), concrete.other(vertices.w))
        XCTAssertEqual(sut.weight, concrete.weight)
        XCTAssertEqual(sut.tail, concrete.tail)
        XCTAssertEqual(sut.head, concrete.head)
        
        XCTAssertEqual(sut.reversed(), AnyWeightedGraphEdge(concrete.reversed()))
        let newWeight = Double.random(in: 10.0..<100.0)
        XCTAssertEqual(sut.reversedWith(weight: newWeight), AnyWeightedGraphEdge(concrete.reversedWith(weight: newWeight)))
    }
    
}
