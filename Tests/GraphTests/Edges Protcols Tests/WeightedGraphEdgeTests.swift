//
//  WeightedGraphEdgeTests.swift
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

final class WeightedGraphEdgeTests: XCTestCase {
    var sut: DummyWeightedGraphEdge<Double>!
    
    override func setUp() {
        super.setUp()
        
        let vertices = givenTwoRandomAndDistinctVertices
        sut = DummyWeightedGraphEdge(v: vertices.v, w: vertices.w, weight: Double.random(in: 0..<10.0))
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    func testReverseWithWeight() {
        let newWeight = Double.random(in: 10.0..<100.0)
        let reversed = sut.reversedWith(weight: newWeight)
        XCTAssertEqual(reversed.weight, newWeight)
        XCTAssertTrue(sut <~> reversed)
    }
    
    func testEquatable() {
        var rhs = DummyWeightedGraphEdge(v: sut.tail, w: sut.head, weight: sut.weight)
        XCTAssertEqual(sut.either, rhs.either)
        XCTAssertEqual(sut.other(sut.either), rhs.other(rhs.either))
        XCTAssertEqual(sut.weight, rhs.weight)
        XCTAssertEqual(sut, rhs)
        
        rhs = DummyWeightedGraphEdge(v: sut.tail, w: sut.head, weight: Double.random(in: 10.0..<100.0))
        XCTAssertEqual(sut.either, rhs.either)
        XCTAssertEqual(sut.other(sut.either), rhs.other(rhs.either))
        XCTAssertNotEqual(sut.weight, rhs.weight)
        XCTAssertNotEqual(sut, rhs)
        
        rhs = DummyWeightedGraphEdge(v: sut.tail + 2, w: sut.head, weight: sut.weight)
        XCTAssertNotEqual(sut.either, rhs.either)
        XCTAssertEqual(sut.other(sut.either), rhs.other(rhs.either))
        XCTAssertEqual(sut.weight, rhs.weight)
        XCTAssertNotEqual(sut, rhs)
        
        rhs = DummyWeightedGraphEdge(v: sut.tail, w: sut.head + 2, weight: sut.weight)
        XCTAssertEqual(sut.either, rhs.either)
        XCTAssertNotEqual(sut.other(sut.either), rhs.other(rhs.either))
        XCTAssertEqual(sut.weight, rhs.weight)
        XCTAssertNotEqual(sut, rhs)
    }
    
    func testHashable() {
        var set: Set<DummyWeightedGraphEdge<Double>> = []
        var rhs = DummyWeightedGraphEdge(v: sut.tail, w: sut.head, weight: sut.weight)
        XCTAssertEqual(sut, rhs)
        set.insert(sut)
        XCTAssertFalse(set.insert(rhs).inserted)
        XCTAssertEqual(set.count, 1)
        
        set.removeAll()
        set.insert(sut)
        rhs = DummyWeightedGraphEdge(v: sut.tail + 2, w: sut.head, weight: sut.weight)
        XCTAssertNotEqual(sut, rhs)
        XCTAssertTrue(set.insert(rhs).inserted)
        XCTAssertEqual(set.count, 2)
    }
    
    func testUndirectedSameWeightComparator() {
        var rhs = DummyWeightedGraphEdge(v: sut.head, w: sut.tail, weight: sut.weight)
        XCTAssertNotEqual(sut, rhs)
        XCTAssertTrue(sut <~> rhs)
        XCTAssertTrue(sut <=~=> rhs)
        
        rhs = DummyWeightedGraphEdge(v: sut.head, w: sut.tail, weight: sut.weight + Double.random(in: 0.5..<20.0))
        XCTAssertNotEqual(sut, rhs)
        XCTAssertTrue(sut <~> rhs)
        XCTAssertFalse(sut <=~=> rhs)
        
        rhs = DummyWeightedGraphEdge(v: sut.tail + 2, w: sut.head, weight: sut.weight)
        XCTAssertNotEqual(sut, rhs)
        XCTAssertFalse(sut <~> rhs)
        XCTAssertFalse(sut <=~=> rhs)
    }
    
}
