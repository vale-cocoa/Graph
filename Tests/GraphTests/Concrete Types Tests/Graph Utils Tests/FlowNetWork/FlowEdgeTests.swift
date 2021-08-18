//
//  FlowEdgeTests.swift
//  GraphTests
//
//  Created by Valeriano Della Longa on 2021/08/18.
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

final class FlowEdgeTests: XCTestCase {
    typealias G = AdjacencyList<WeightedEdge<Double>>
    
    typealias FlowEdge = FlowNetwork<G>.FlowEdge
    
    var sut: FlowEdge!
    
    override func setUp() {
        super.setUp()
        
        let e = WeightedEdge(tail: Int.random(in: 0..<10), head: Int.random(in: 10..<20), weight: Double.random(in: .zero...1.0))
        sut = try? FlowEdge(e)
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    func testInit() {
        // When given edge weight is non-negative:
        var e = WeightedEdge(tail: Int.random(in: 0..<10), head: Int.random(in: 10..<20), weight: Double.random(in: 0.0...1.0))
        XCTAssertNoThrow(sut = try FlowEdge(e))
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.from, e.tail)
        XCTAssertEqual(sut.to, e.head)
        XCTAssertEqual(sut.capacity, e.weight)
        XCTAssertEqual(sut.flow, .zero)
        
        // When given edge weight is negative, then throws error
        e.weight = -1.0
        do {
            let _ = try FlowEdge(e)
            XCTFail("Did't throw")
        } catch {
            XCTAssertEqual(error as NSError, FlowNetwork<G>.Error.negativeWeightedEdge as NSError)
        }
    }
    
    func testOtherVertex() {
        let v = sut.from
        let w = sut.to
        XCTAssertEqual(sut.other(v), w)
        XCTAssertEqual(sut.other(w), v)
    }
    
    func testResidualCapacityTo() {
        let v = sut.from
        let w = sut.to
        XCTAssertEqual(sut.residualCapacity(to: v), sut.flow)
        XCTAssertEqual(sut.residualCapacity(to: w), (sut.capacity - sut.flow))
    }
    
}
