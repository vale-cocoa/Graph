//
//  GraphBipartiteTests.swift
//  GraphTests
//
//  Created by Valeriano Della Longa on 2021/05/12.
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

final class GraphBipartiteTests: XCTestCase {
    var sut: GraphBipartite<AdjacencyList<WeightedEdge<Double>>>!
    
    override func setUp() {
        super.setUp()
        
        let edges = givenRandomWeightedEdges()
        let kind = GraphConnections.allCases.randomElement()!
        let graph = AdjacencyList(kind: kind, edges: edges)
        sut = GraphBipartite(graph: graph)
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - WHEN
    func whenGraphHasNoEdges() {
        let vertexCount = Int.random(in: 10..<100)
        let kind = GraphConnections.allCases.randomElement()!
        let graph = AdjacencyList<WeightedEdge<Double>>(kind: kind, vertexCount: vertexCount)
        sut = GraphBipartite(graph: graph)
    }
    
    func whenGraphIsBipartite() {
        // Partitions are vertices in 0..<(vertexCount / 2)
        // and vertices in (vertexCount / 2)..<vertexCount:
        let vertexCount = Int.random(in: 10..<100)
        var edges = Array<WeightedEdge<Double>>()
        for tail in 0..<(vertexCount / 2) {
            let weight = Double.random(in: 0.5..<10.5)
            edges.append(WeightedEdge(tail: tail, head: tail + (vertexCount / 2), weight: weight))
        }
        let kind = GraphConnections.allCases.randomElement()!
        let graph = AdjacencyList(kind: kind, edges: edges)
        sut = GraphBipartite(graph: graph)
    }
    
    func whenGraphIsNotBipartite() {
        let vertexCount = Int.random(in: 10..<100)
        var edges = Array<WeightedEdge<Double>>()
        for tail in 0..<(vertexCount / 2) {
            let weight = Double.random(in: 0.5..<10.5)
            edges.append(WeightedEdge(tail: tail, head: tail + (vertexCount / 2), weight: weight))
        }
        // We'll add a cycle in one of the two partitions so graph
        // can't be anymore bipartite:
        edges.append(WeightedEdge(tail: 0, head: 1, weight: 100.0))
        edges.append(WeightedEdge(tail: 0, head: 2, weight: 110.0))
        edges.append(WeightedEdge(tail: 1, head: 2, weight: 115.0))
        let kind = GraphConnections.allCases.randomElement()!
        let graph = AdjacencyList(kind: kind, edges: edges)
        sut = GraphBipartite(graph: graph)
    }
    
    // MARK: - Tests
    func testInitGraph() {
        let edges = givenRandomWeightedEdges()
        let kind = GraphConnections.allCases.randomElement()!
        let graph = AdjacencyList(kind: kind, edges: edges)
        sut = GraphBipartite(graph: graph)
        
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.graph, graph)
    }
    
    // MARK: - isBipartite tests
    func testIsBiPartite_whenGraphHasNoEdges_thenReturnsTrue() {
        whenGraphHasNoEdges()
        XCTAssertTrue(sut.isBiPartite)
    }
    
    func testIsBipartite_whenGraphIsBipartite_thenReturnsTrue() {
        whenGraphIsBipartite()
        XCTAssertTrue(sut.isBiPartite)
    }
    
    func testIsBipartite_whenGraphIsNotBipartite_thenReturnsFalse() {
        whenGraphIsNotBipartite()
        XCTAssertFalse(sut.isBiPartite)
    }
    
    // MARK: - isColored(_:) tests
    func testIsColored_whenGraphHasNoEdges_thenReturnsFalseForEachVertex() {
        whenGraphHasNoEdges()
        for vertex in 0..<sut.graph.vertexCount {
            XCTAssertFalse(sut.isColored(vertex))
        }
    }
    
    func testIsColored_whenGraphsIsBipartite() {
        whenGraphIsBipartite()
        // returns false for vertices in first partition:
        let vCount = sut.graph.vertexCount
        for vertex in 0..<(vCount / 2) {
            XCTAssertFalse(sut.isColored(vertex))
        }
        // returns true for vertices in second partition:
        for vertex in (vCount / 2)..<vCount {
            XCTAssertTrue(sut.isColored(vertex))
        }
    }
    
    func testIsColored_whenGraphIsNotBipartite() {
        // returns same value for those vertices creating
        // the cycle in the partition which makes the graph not bipartite:
        whenGraphIsNotBipartite()
        XCTAssertEqual(sut.isColored(0), sut.isColored(2))
    }
    
    func testCountOfColoredVertices_whenGraphHasNoEdges_thenReturnsZero() {
        whenGraphHasNoEdges()
        XCTAssertEqual(sut.countOfColoredVertex, 0)
    }
    
    func testCountOfColoredVertices_whenGraphIsBipartite() {
        whenGraphIsBipartite()
        let expectedResult = (0..<sut.graph.vertexCount).reduce(0, { sut.isColored($1) ?  $0 + 1 : $0 })
        XCTAssertEqual(sut.countOfColoredVertex, expectedResult)
    }
    
    func testCountOfColoredVertices_whenGraphIsNotBipartite() {
        whenGraphIsNotBipartite()
        let expectedResult = (0..<sut.graph.vertexCount).reduce(0, { sut.isColored($1) ?  $0 + 1 : $0 })
        XCTAssertEqual(sut.countOfColoredVertex, expectedResult)
    }
    
    func testCountOfNotColoredVertices_whenGraphHasNoEdges_thenReturnsSameValueOfGraphVertexCount() {
        whenGraphHasNoEdges()
        XCTAssertEqual(sut.countOfNotColoredVertex, sut.graph.vertexCount)
    }
    
    func testCountOfNotColoredVertices_whenGraphIsBipartite() {
        whenGraphIsBipartite()
        let expectedResult = (0..<sut.graph.vertexCount).reduce(0, { sut.isColored($1) ?  $0 : $0 + 1 })
        XCTAssertEqual(sut.countOfNotColoredVertex, expectedResult)
    }
    
    func testCountOfNotColoredVertices_whenGraphIsNotBipartite() {
        whenGraphIsNotBipartite()
        let expectedResult = (0..<sut.graph.vertexCount).reduce(0, { sut.isColored($1) ?  $0 : $0 + 1 })
        XCTAssertEqual(sut.countOfNotColoredVertex, expectedResult)
    }
    
}
