//
//  GraphHamiltonPathTests.swift
//  GraphTests
//
//  Created by Valeriano Della Longa on 2021/12/23.
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

final class GraphHamiltonPathTests: XCTestCase {
    var sut: GraphHamiltonPath<AdjacencyList<WeightedEdge<Double>>>!
    
    override func setUp() {
        super.setUp()
        
        whenGraphHasNoVertices(kind: GraphConnections.allCases.randomElement()!)
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - When
    func whenGraphHasNoVertices(kind: GraphConnections) {
        sut = GraphHamiltonPath(graph: AdjacencyList(kind: kind, vertexCount: 0))
    }
    
    func whenGraphHasNoEdges(kind: GraphConnections) {
        let vertexCount = Int.random(in: 10..<100)
        sut = GraphHamiltonPath(graph: AdjacencyList(kind: kind, vertexCount: vertexCount))
    }
    
    func whenGraphHasEdgesAndNoHamiltonianPath(kind: GraphConnections) {
        var graph = AdjacencyList<WeightedEdge<Double>>(kind: kind, vertexCount: Int.random(in: 3..<100))
        (0..<(graph.vertexCount - 2)).forEach {
            let edge = WeightedEdge(tail: $0, head: $0 + 1, weight: Double.random(in: 0.0...1.0))
            graph.add(edge: edge)
        }
        sut = GraphHamiltonPath(graph: graph)
    }
    
    func whenGraphContainsHamiltonianPath(kind: GraphConnections) {
        var graph = AdjacencyList<WeightedEdge<Double>>(kind: kind, vertexCount: Int.random(in: 3..<100))
        (0..<(graph.vertexCount - 1)).forEach {
            let edge = WeightedEdge(tail: $0, head: $0 + 1, weight: Double.random(in: 0.0...1.0))
            graph.add(edge: edge)
        }
        sut = GraphHamiltonPath(graph: graph)
    }
    
    func whenGraphContainsMultipleHamiltoninanPaths(kind: GraphConnections) {
        var graph = AdjacencyList<WeightedEdge<Double>>(kind: kind, vertexCount: Int.random(in: 3..<10))
        (0..<(graph.vertexCount - 1)).forEach {
            let edge1 = WeightedEdge(tail: $0, head: $0 + 1, weight: Double.random(in: 0.0...1.0))
            var edge2 = edge1
            edge2.weight = Double.random(in: 1.1...2.0)
            graph.add(edge: edge1)
            graph.add(edge: edge2)
        }
        
        sut = GraphHamiltonPath(graph: graph)
    }
    
    // MARK: - Tests
    func testInitGraph() {
        let kind = GraphConnections.allCases.randomElement()!
        let edges = givenRandomWeightedEdges()
        let graph = AdjacencyList(kind: kind, edges: edges)
        sut = GraphHamiltonPath(graph: graph)
        
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.graph, graph)
    }
    
    func testHamiltonianPaths_whenGraphHasNoVertices_thenIsEmpty() {
        for kind in GraphConnections.allCases {
            whenGraphHasNoVertices(kind: kind)
            
            XCTAssertTrue(sut.hamiltonianPaths.isEmpty)
        }
    }
    
    func testHamiltonianPaths_whenGraphHasNoEdges_thenIsEmpty() {
        for kind in GraphConnections.allCases {
            whenGraphHasNoEdges(kind: kind)
            
            XCTAssertTrue(sut.hamiltonianPaths.isEmpty)
        }
    }
    
    func testHamiltonianPaths_whenGraphHasEdgesAndNotAllVerticesAreConnected_thenIsEmpty() {
        for kind in GraphConnections.allCases {
            whenGraphHasEdgesAndNoHamiltonianPath(kind: kind)
            
            XCTAssertTrue(sut.hamiltonianPaths.isEmpty)
            XCTAssertEqual(sut.hamiltonianPaths, [])
        }
    }
    
    func testHamiltonianPaths_whenGraphContainsHamiltonianPath_thenIsNotEmptyAndContainsThePath() {
        for kind in GraphConnections.allCases {
            whenGraphContainsHamiltonianPath(kind: kind)
            
            XCTAssertFalse(sut.hamiltonianPaths.isEmpty)
            sut.hamiltonianPaths.forEach {
                XCTAssertTrue($0.isHamiltonianPath(vertexCount: sut.graph.vertexCount))
            }
        }
    }
    
    func testHamiltonianPaths_whenGraphContainsMultipleHamiltonianPaths_thenIsNotEmptyAndContainsHamiltonianPaths() {
        for kind in GraphConnections.allCases {
            whenGraphContainsMultipleHamiltoninanPaths(kind: kind)
            
            XCTAssertFalse(sut.hamiltonianPaths.isEmpty)
            XCTAssertTrue(sut.hamiltonianPaths.count > 1)
            sut.hamiltonianPaths.forEach {
                XCTAssertTrue($0.isHamiltonianPath(vertexCount: sut.graph.vertexCount))
            }
        }
    }
    
}

extension Collection where Element: GraphEdge {
    fileprivate func isHamiltonianPath(vertexCount: Int) -> Bool {
        precondition(vertexCount > 1)
        guard
            self.count == vertexCount - 1
        else { return false }
        
        var sources = Set<Int>()
        var destinations = Set<Int>()
        for edge in self {
            let v = edge.either
            let w = edge.other(v)
            if sources.insert(v).inserted {
                guard
                    destinations.insert(w).inserted
                else { return false }
            } else {
                guard
                    destinations.insert(v).inserted,
                    sources.insert(w).inserted
                else { return false }
            }
        }
        
        return sources
            .union(destinations)
            .sorted()
            .elementsEqual(0..<vertexCount)
    }
    
}
