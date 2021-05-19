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
    
    func givenRandomSources<G: Graph>(_ graph: G) -> Set<Int> {
        var vertices = Array(0..<graph.vertexCount).shuffled()
        let k = Int.random(in: 0..<(graph.vertexCount - 1))
        vertices.removeLast(k)
        
        return Set(vertices)
    }
    
    // MARK: - When
    func whenGraphHasNoEdgesRandomSources(kind: GraphConnections) {
        let graph = givenGraphWithNoEdges(kind: kind)
        let sources = givenRandomSources(graph)
        sut = GraphReachability(graph: graph, sources: sources)
    }
    
    func whenGraphHasEdgesRandomSources(kind: GraphConnections) {
        let graph = givenGraphWithEdges(kind: kind)
        let sources = givenRandomSources(graph)
        sut = GraphReachability(graph: graph, sources: sources)
    }
    
    // MARK: - Tests
    func testInitGraphSources() {
        let graph = givenGraphWithEdges(kind: GraphConnections.allCases.randomElement()!)
        let sources = givenRandomSources(graph)
        sut = GraphReachability(graph: graph, sources: sources)
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.graph, graph)
        XCTAssertEqual(sut.sources, Set(sources))
    }
    
    func testIsReachableFromSources_whenGraphHasNoEdges() {
        whenGraphHasNoEdgesRandomSources(kind: .directed)
        for destination in 0..<sut.graph.vertexCount {
            if sut.sources.contains(destination) {
                XCTAssertTrue(sut.isReachableFromSources(destination))
            } else {
                XCTAssertFalse(sut.isReachableFromSources(destination))
            }
        }
        
        whenGraphHasNoEdgesRandomSources(kind: .undirected)
        for destination in 0..<sut.graph.vertexCount {
            if sut.sources.contains(destination) {
                XCTAssertTrue(sut.isReachableFromSources(destination))
            } else {
                XCTAssertFalse(sut.isReachableFromSources(destination))
            }
        }
    }
    
    func testIsReachableFromSources_whenGraphHasEdges() {
        whenGraphHasEdgesRandomSources(kind: .directed)
        var visited: Set<Int> = []
        for source in sut.sources {
            visited.formUnion(sut.graph.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: source, {_ in }))
        }
        for destination in 0..<sut.graph.vertexCount {
            XCTAssertEqual(sut.isReachableFromSources(destination), visited.contains(destination))
        }
        
        whenGraphHasEdgesRandomSources(kind: .undirected)
        visited = []
        for source in sut.sources {
            visited.formUnion(sut.graph.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: source, {_ in }))
        }
        for destination in 0..<sut.graph.vertexCount {
            XCTAssertEqual(sut.isReachableFromSources(destination), visited.contains(destination))
        }
    }
    
}

// MARK: - Tests for default implementation methods isReachable(_:source) and isReachable(_:sources:)
final class GraphInPlaceReachabilityTests: XCTestCase {
    var sut: AdjacencyList<WeightedEdge<Double>>!
    
    override func setUp() {
        super.setUp()
        
        let kind = GraphConnections.allCases.randomElement()!
        let vertexCount = Int.random(in: 10..<100)
        sut = AdjacencyList<WeightedEdge<Double>>(kind: kind, vertexCount: vertexCount)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Given
    var givenRandomSources: Set<Int> {
        var vertices = Array(0..<sut.vertexCount).shuffled()
        let k = Int.random(in: 0..<(sut.vertexCount - 1))
        vertices.removeLast(k)
        
        return Set(vertices)
    }
    
    // MARK: - When
    func whenGraphHasNoEdges(kind: GraphConnections) {
        let vertexCount = Int.random(in: 10..<100)
        sut = AdjacencyList<WeightedEdge<Double>>(kind: kind, vertexCount: vertexCount)
    }
    
    func whenGraphHasEdges(kind: GraphConnections) {
        let edges = givenRandomWeightedEdges()
        sut = AdjacencyList(kind: kind, edges: edges)
    }
    
    // MARK: - isReachable(_:source:) tests
    func testIsReachableSource_whenGraphHasNoEdges() {
        whenGraphHasNoEdges(kind: .directed)
        for source in 0..<sut.vertexCount {
            for destination in 0..<sut.vertexCount where source != destination {
                XCTAssertFalse(sut.isReachable(destination, from: source))
            }
            XCTAssertTrue(sut.isReachable(source, from: source))
        }
        
        whenGraphHasNoEdges(kind: .undirected)
        for source in 0..<sut.vertexCount {
            for destination in 0..<sut.vertexCount where source != destination {
                XCTAssertFalse(sut.isReachable(destination, from: source))
            }
            XCTAssertTrue(sut.isReachable(source, from: source))
        }
    }
    
    func testIsReachableSource_whenGraphHasEdges() {
        whenGraphHasEdges(kind: .directed)
        var visited = Set<Int>()
        for source in 0..<sut.vertexCount {
            visited = sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: source, { _ in })
            for destination in 0..<sut.vertexCount where source != destination {
                XCTAssertEqual(sut.isReachable(destination, from: source), visited.contains(destination))
            }
        }
        
        whenGraphHasEdges(kind: .undirected)
        for source in 0..<sut.vertexCount {
            visited = sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: source, { _ in })
            for destination in 0..<sut.vertexCount where source != destination {
                XCTAssertEqual(sut.isReachable(destination, from: source), visited.contains(destination))
            }
        }
    }
    
    // MARK: - isReachable(_:sources:) tests
    func testIsReachableSources_whenGraphHasNoEdges() {
        whenGraphHasNoEdges(kind: .directed)
        var sources = givenRandomSources
        for destination in 0..<sut.vertexCount where !sources.contains(destination) {
            XCTAssertFalse(sut.isReachable(destination, from: sources))
        }
        for destination in sources {
            XCTAssertTrue(sut.isReachable(destination, from: sources))
        }
        
        whenGraphHasNoEdges(kind: .undirected)
        sources = givenRandomSources
        for destination in 0..<sut.vertexCount where !sources.contains(destination) {
            XCTAssertFalse(sut.isReachable(destination, from: sources))
        }
        for destination in sources {
            XCTAssertTrue(sut.isReachable(destination, from: sources))
        }
    }
    
    func testIsReachableSources_whenGraphHasEdges() {
        whenGraphHasEdges(kind: .directed)
        var sources = givenRandomSources
        var visited = Set<Int>()
        for source in sources {
            visited.formUnion(sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: source, {_ in }))
        }
        for destination in 0..<sut.vertexCount {
            XCTAssertEqual(sut.isReachable(destination, from: sources), visited.contains(destination))
        }
        
        whenGraphHasEdges(kind: .undirected)
        sources = givenRandomSources
        visited = []
        for source in sources {
            visited.formUnion(sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: source, {_ in }))
        }
        for destination in 0..<sut.vertexCount {
            XCTAssertEqual(sut.isReachable(destination, from: sources), visited.contains(destination))
        }
    }
    
}
