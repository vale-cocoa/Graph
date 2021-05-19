//
//  GraphTCTests.swift
//  GraphTests
//
//  Created by Valeriano Della Longa on 2021/05/18.
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

final class GraphTCTests: XCTestCase {
    var sut: GraphTransitiveClosure<AdjacencyList<WeightedEdge<Double>>>!
    
    override func setUp() {
        super.setUp()
        
        let graph = AdjacencyList(kind: GraphConnections.allCases.randomElement()!, edges: givenRandomWeightedEdges())
        sut = GraphTransitiveClosure(graph: graph)
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - When
    func whenGraphHasNoEdges(kind: GraphConnections) {
        let verticesCount = Int.random(in: 10..<100)
        let graph = AdjacencyList<WeightedEdge<Double>>(kind: kind, vertexCount: verticesCount)
        sut = GraphTransitiveClosure(graph: graph)
    }
    
    func whenGraphHasEdges(kind: GraphConnections) {
        let edges = givenRandomWeightedEdges()
        let graph = AdjacencyList(kind: kind, edges: edges)
        sut = GraphTransitiveClosure(graph: graph)
    }
    
    // MARK: - Tests
    func testInitGraph() {
        let kind = GraphConnections.allCases.randomElement()!
        let edges = givenRandomWeightedEdges()
        let graph = AdjacencyList(kind: kind, edges: edges)
        sut = GraphTransitiveClosure(graph: graph)
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.graph, graph)
    }
    
    func testReachability_whenGraphHasNoEdges_thenAlwaysReturnsFalseForVerticesDifferentThanSource() {
        whenGraphHasNoEdges(kind: .directed)
        for source in 0..<sut.graph.vertexCount {
            for destination in 0..<sut.graph.vertexCount where destination != source {
                XCTAssertFalse(sut.reachability(from: source, to: destination))
            }
            XCTAssertTrue(sut.reachability(from: source, to: source))
        }
        
        whenGraphHasNoEdges(kind: .undirected)
        for source in 0..<sut.graph.vertexCount {
            for destination in 0..<sut.graph.vertexCount where destination != source {
                XCTAssertFalse(sut.reachability(from: source, to: destination))
            }
            XCTAssertTrue(sut.reachability(from: source, to: source))
        }
    }
    
    func testReachability_whenGraphHasEdges_thenReturnsResultAccordinglyToReachabilityFromSourceToDestination() {
        // To check the exactness of the result, we build a visited set of vertices
        // doing a Breadth First Search traverse of the graph from each source vertex,
        // then we check every result from every possible destination against if such
        // destination vertex is included in the visited set.
        // That is the visitedVertices(adopting:reachableFrom:_:) method of the graph
        // always returns a set of vertices in the graph reachable from the source vertex.
        whenGraphHasEdges(kind: .directed)
        for source in 0..<sut.graph.vertexCount {
            let visited = sut.graph.visitedVertices(adopting: .BreadthFirstSearch, reachableFrom: source, {_ in })
            for destination in 0..<sut.graph.vertexCount {
                XCTAssertEqual(sut.reachability(from: source, to: destination), visited.contains(destination))
            }
        }
        
        whenGraphHasEdges(kind: .undirected)
        for source in 0..<sut.graph.vertexCount {
            let visited = sut.graph.visitedVertices(adopting: .BreadthFirstSearch, reachableFrom: source, {_ in })
            for destination in 0..<sut.graph.vertexCount {
                XCTAssertEqual(sut.reachability(from: source, to: destination), visited.contains(destination))
            }
        }
    }
    
    func testReachability_memoization() {
        whenGraphHasEdges(kind: .directed)
        var results = Array<Set<Int>>(repeating: [], count: sut.graph.vertexCount)
        for source in 0..<sut.graph.vertexCount {
            for destination in 0..<sut.graph.vertexCount {
                guard sut.reachability(from: source, to: destination) else { continue }
                
                results[source].insert(destination)
            }
        }
        for source in 0..<sut.graph.vertexCount {
            for destination in 0..<sut.graph.vertexCount {
                XCTAssertEqual(sut.reachability(from: source, to: destination), results[source].contains(destination))
            }
        }
    }
    
}
