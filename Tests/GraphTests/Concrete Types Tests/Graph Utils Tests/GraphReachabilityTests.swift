//
//  GraphReachabilityTests.swift
//  GraphTests
//
//  Created by Valeriano Della Longa on 2021/05/14.
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

final class GraphReachabilityTests: XCTestCase {
    var sut: GraphReachability<AdjacencyList<WeightedEdge<Double>>>!
    
    override func setUp() {
        super.setUp()
        
        let graph = givenGraphWithEdges(kind: GraphConnections.allCases.randomElement()!)
        var sources = (0..<graph.vertexCount).shuffled()
        sources.removeLast(Int.random(in: 1..<graph.vertexCount))
        sut = GraphReachability(graph: graph, sources: Set(sources))
    }
    
    // MARK: - Given
    func givenGraphWithNoEdges(kind: GraphConnections) -> AdjacencyList<WeightedEdge<Double>> {
        let vertexCount = Int.random(in: 10..<100)
        
        return AdjacencyList<WeightedEdge<Double>>(kind: kind, vertexCount: vertexCount)
    }
    
    func givenGraphWithEdges(kind: GraphConnections) -> AdjacencyList<WeightedEdge<Double>> {
        let edges = givenRandomWeightedEdges()
        
        return AdjacencyList(kind: kind, edges: edges)
    }
    
    // MARK: - Tests
    func testInitGraphSources() {
        let graph = givenGraphWithEdges(kind: GraphConnections.allCases.randomElement()!)
        var sources = (0..<graph.vertexCount).shuffled()
        sources.removeLast(Int.random(in: 1..<graph.vertexCount))
        sut = GraphReachability(graph: graph, sources: Set(sources))
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.graph, graph)
        XCTAssertEqual(sut.sources, Set(sources))
    }
    
    func testIsReachableFromSources_whenGraphHasNoEdges() {
        var graph = givenGraphWithNoEdges(kind: .directed)
        var sources = (0..<graph.vertexCount).shuffled()
        sources.removeLast(Int.random(in: 1..<graph.vertexCount))
        sut = GraphReachability(graph: graph, sources: Set(sources))
        for destination in 0..<graph.vertexCount {
            if sut.sources.contains(destination) {
                XCTAssertTrue(sut.isReachableFromSources(destination))
            } else {
                XCTAssertFalse(sut.isReachableFromSources(destination))
            }
        }
        
        graph = givenGraphWithNoEdges(kind: .undirected)
        sources = (0..<graph.vertexCount).shuffled()
        sources.removeLast(Int.random(in: 1..<graph.vertexCount))
        sut = GraphReachability(graph: graph, sources: Set(sources))
        for destination in 0..<graph.vertexCount {
            if sut.sources.contains(destination) {
                XCTAssertTrue(sut.isReachableFromSources(destination))
            } else {
                XCTAssertFalse(sut.isReachableFromSources(destination))
            }
        }
    }
    
    func testIsReachableFromSources_whenGraphHasEdges() {
        var graph = givenGraphWithEdges(kind: .directed)
        var sources = (0..<graph.vertexCount).shuffled()
        sources.removeLast(Int.random(in: 1..<graph.vertexCount))
        sut = GraphReachability(graph: graph, sources: Set(sources))
        var visited: Set<Int> = []
        for source in sources {
            visited.formUnion(graph.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: source, {_ in }))
        }
        for destination in 0..<graph.vertexCount {
            XCTAssertEqual(sut.isReachableFromSources(destination), visited.contains(destination))
        }
        
        graph = givenGraphWithEdges(kind: .undirected)
        sources = (0..<graph.vertexCount).shuffled()
        sources.removeLast(Int.random(in: 1..<graph.vertexCount))
        sut = GraphReachability(graph: graph, sources: Set(sources))
        visited.removeAll(keepingCapacity: true)
        for source in sources {
            visited.formUnion(graph.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: source, {_ in }))
        }
        for destination in 0..<graph.vertexCount {
            XCTAssertEqual(sut.isReachableFromSources(destination), visited.contains(destination))
        }
    }
    
}
