//
//  GraphHashableTests.swift
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

final class GraphHashableTests: GraphBaseTests {
    func testAreEqual_whenKindOrVertexCountOrEdgeCountValuesAreDifferent_thenReturnsFalse() {
        var lhs = AdjacencyList<WeightedEdge<Double>>(kind: .directed, vertexCount: 10)
        var rhs = AdjacencyList<WeightedEdge<Double>>(kind: .undirected, vertexCount: 10)
        XCTAssertNotEqual(lhs, rhs)
        
        lhs = AdjacencyList<WeightedEdge<Double>>(kind: .directed, vertexCount: 10)
        rhs = AdjacencyList<WeightedEdge<Double>>(kind: .directed, vertexCount: Int.random(in: 11..<20))
        XCTAssertNotEqual(lhs, rhs)
        
        rhs = AdjacencyList<WeightedEdge<Double>>(kind: .directed, vertexCount: 10)
        rhs.add(edge: WeightedEdge<Double>(tail: 0, head: 1, weight: 10.5))
        XCTAssertNotEqual(lhs.edgeCount, rhs.edgeCount)
        XCTAssertNotEqual(lhs, rhs)
    }
    
    func testAreEqual_whenKindAnVertexCountAndEdgeCountValuesAreEqualAndAdjacenciesAreSameButInDifferentOrder_thenReturnsFalse() {
        var lhs = AdjacencyList<WeightedEdge<Double>>(kind: .directed, vertexCount: 10)
        var rhs = AdjacencyList<WeightedEdge<Double>>(kind: .directed, vertexCount: 10)
        let edge1 = WeightedEdge<Double>(tail: 0, head: 1, weight: 10.5)
        let edge2 = WeightedEdge<Double>(tail: 0, head: 2, weight: 10.5)
        lhs.add(edge: edge1)
        lhs.add(edge: edge2)
        rhs.add(edge: edge2)
        rhs.add(edge: edge1)
        
        XCTAssertNotEqual(lhs.adjacencies(vertex: edge1.tail), rhs.adjacencies(vertex: edge1.tail))
        XCTAssertNotEqual(lhs, rhs)
    }
    
    func testAreEqual_whenKindAnVertexCountAndEdgeCountValuesAreEqualAndAdjacenciesAreEqualAndInSameOrder_thenReturnsTrue() {
        var lhs = AdjacencyList<WeightedEdge<Double>>(kind: .directed, vertexCount: 10)
        var rhs = AdjacencyList<WeightedEdge<Double>>(kind: .directed, vertexCount: 10)
        let edge1 = WeightedEdge<Double>(tail: 0, head: 1, weight: 10.5)
        let edge2 = WeightedEdge<Double>(tail: 0, head: 2, weight: 10.5)
        lhs.add(edge: edge1)
        lhs.add(edge: edge2)
        rhs.add(edge: edge1)
        rhs.add(edge: edge2)
        
        XCTAssertEqual(lhs.adjacencies(vertex: edge1.tail), rhs.adjacencies(vertex: edge1.tail))
        XCTAssertEqual(lhs, rhs)
    }
    
    func testHashable() {
        var set: Set<AdjacencyList<WeightedEdge<Double>>> = []
        whenKindIsDirectedAndContainsEdges()
        set.insert(sut)
        var other = sut!
        XCTAssertFalse(set.insert(other).inserted)
        
        other.reverse()
        XCTAssertNotEqual(other, sut)
        XCTAssertTrue(set.insert(other).inserted)
    }
    
}
