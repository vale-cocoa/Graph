//
//  GraphSPTests.swift
//  GraphTests
//
//  Created by Valeriano Della Longa on 2021/08/10.
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

final class GraphSPTests: XCTestCase {
    var sut: GraphSP<AdjacencyList<WeightedEdge<Double>>>!
    
    override func setUp() {
        super.setUp()
        let edges = givenRandomWeightedEdges()
        let graph = AdjacencyList(kind: .allCases.randomElement()!, edges: edges)
        let source = (0..<graph.vertexCount).randomElement()!
        sut = GraphSP(graph: graph, source: source)
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - When
    func whenGraphHasNoEdges() {
        let vcount = Int.random(in: 10..<1000)
        let graph = AdjacencyList<WeightedEdge<Double>>(kind: .allCases.randomElement()!, vertexCount: vcount)
        let source = (0..<vcount).randomElement()!
        sut = GraphSP(graph: graph, source: source)
    }
    
    func whenGraphHasEdges() {
        let edges = givenRandomWeightedEdges()
        let graph = AdjacencyList(kind: .allCases.randomElement()!, edges: edges)
        let source = (0..<graph.vertexCount).randomElement()!
        sut = GraphSP(graph: graph, source: source)
    }
    
    func whenGraphHasNoNegativeCycleAndNoNegativeWeights() {
        let graph = givenTinyEWDAG()
        sut = GraphSP(graph: graph, source: 0)
    }
    
    func whenGraphHasNoNegativeCycleAndSomeNegativeWeights() {
        let graph = givenTinyEWDn()
        sut = GraphSP(graph: graph, source: 0)
    }
    
    func whenGraphHasNegativeCycle() {
        let graph = givenTinyEWDnc()
        sut = GraphSP(graph: graph, source: 0)
    }
    
    // MARK: - Tests
    func testInit() {
        let edges = givenRandomWeightedEdges()
        let graph = AdjacencyList(kind: .allCases.randomElement()!, edges: edges)
        let source = (0..<graph.vertexCount).randomElement()!
        
        sut = GraphSP(graph: graph, source: source)
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.graph, graph)
        XCTAssertEqual(sut.source, source)
    }
    
    // MARK: - weight(to:) tests
    func testWeightTo_whenGraphHasNoEdges_thenReturnsNilForAnyDestinationVertexDifferentFromSource() {
        whenGraphHasNoEdges()
        for destination in 0..<sut.graph.vertexCount where destination != sut.source {
            XCTAssertNil(sut.weight(to: destination))
        }
    }
    
    func testWeightTo_whenDestinationIsEqualToSource_thenReturnsZero() {
        whenGraphHasNoEdges()
        var destination = sut.source
        XCTAssertEqual(sut.weight(to: destination), Double.zero)
        
        whenGraphHasEdges()
        destination = sut.source
        XCTAssertEqual(sut.weight(to: destination), Double.zero)
    }
    
    func testWeightTo_whenGraphHasEdgesAndDestinationIsDifferentThanSource_thenReturnsNilIfThereIsNoPathOtherwiseTotalWeightOfPath() {
        whenGraphHasEdges()
        for destination in 0..<sut.graph.vertexCount where destination != sut.source {
            let expectedResult: Double? = sut.path(to: destination)
                .reduce(nil, { partial, edge in
                    guard
                        let partial = partial
                    else { return edge.weight }
                    
                    return partial + edge.weight
                })
            XCTAssertEqual(sut.weight(to: destination), expectedResult)
        }
    }
    
    // MARK: - hasPath(to:) tests
    func testHasPathTo_whenGraphHasNoEdges_thenReturnsFalseForAnyDestinationVertexDifferentThanSource() {
        whenGraphHasNoEdges()
        for destination in 0..<sut.graph.vertexCount where destination != sut.source {
            XCTAssertFalse(sut.hasPath(to: destination))
        }
    }
    
    func testHasPathTo_whenDestinationIsEqualToSource_thenReturnsTrue() {
        whenGraphHasNoEdges()
        var destination = sut.source
        XCTAssertTrue(sut.hasPath(to: destination))
        
        whenGraphHasEdges()
        destination = sut.source
        XCTAssertTrue(sut.hasPath(to: destination))
    }
    
    func testHasPathTo_whenGraphHasEdges_thenReturnsTrueIfDestinationIsReachableFromSourceOtherWiseFalse() {
        whenGraphHasEdges()
        let reachability = GraphReachability(graph: sut.graph, sources: [sut.source])
        for destination in 0..<sut.graph.vertexCount {
            XCTAssertEqual(sut.hasPath(to: destination), reachability.isReachableFromSources(destination))
        }
    }
    
    // MARK: - path(to:) tests
    func testPathTo_whenGraphHasNoEdges_thenReturnsEmptySequenceForAnyDestinationVertex() {
        whenGraphHasNoEdges()
        OUTER: for destination in 0..<sut.graph.vertexCount {
            let path = sut.path(to: destination)
            for _ in path {
                XCTFail("path is not empty for destination: \(destination)")
                continue OUTER
            }
        }
    }
    
    func testPathTo_whenDestinationIsEqualToSource_thenReturnsEmptySequence() {
        whenGraphHasNoEdges()
        var destination = sut.source
        var path = sut.path(to: destination)
        for _ in path {
            XCTFail("path is not empty when destination is equal to source.")
            break
        }
        
        whenGraphHasEdges()
        destination = sut.source
        path = sut.path(to: destination)
        for _ in path {
            XCTFail("path is not empty when destination is equal to source.")
            break
        }
    }
    
    func testPathTo_whenDestinationIsDifferentFromSourceAndHasPathToDestinationReturnsTrue_thenReturnsSequenceContainingEdgesFromSourceToDestination() {
        whenGraphHasEdges()
        for destination in 0..<sut.graph.vertexCount where destination != sut.source && sut.hasPath(to: destination) == true {
            let path = sut.path(to: destination)
            var pathDest = sut.source
            for edge in path {
                pathDest = edge.other(pathDest)
            }
            XCTAssertEqual(pathDest, destination)
        }
    }
    
    func testPathTo_memoization() {
        whenGraphHasEdges()
        let allGraphVertices = (0..<sut.graph.vertexCount)
        allGraphVertices.forEach {
            let _ = sut.path(to: $0)
        }
        allGraphVertices.shuffled().forEach {
            let _ = sut.path(to: $0)
        }
    }
    
    // MARK: - negativeCycle tests
    func testNegativeCycle_whenGraphHasNoEdges_thenIsEmpty() {
        whenGraphHasNoEdges()
        XCTAssertTrue(sut.negativeCycle.isEmpty)
    }
    
    func testNegativeCycle_whenGraphHasNoNegativeCycleAndNoNegativeWeights_thenIsEmpty() {
        whenGraphHasNoNegativeCycleAndNoNegativeWeights()
        XCTAssertTrue(sut.negativeCycle.isEmpty)
    }
    
    func testNegativeCycle_whenGraphHasNoNegativeCycleAndSomeNegativeWeights_thenIsEmpty() {
        whenGraphHasNoNegativeCycleAndSomeNegativeWeights()
        XCTAssertTrue(sut.negativeCycle.isEmpty)
    }
    
    func testNegativeCycle_whenGraphHasNegativeCycle_thenReturnsArrayContainingVerticesInNegativeCycle() {
        whenGraphHasNegativeCycle()
        let expectedNegativeCycle = [5, 4, 5]
        XCTAssertEqual(sut.negativeCycle, expectedNegativeCycle)
    }
    
}
