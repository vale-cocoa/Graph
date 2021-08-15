//
//  GraphAcyclicSPTests.swift
//  GraphTests
//
//  Created by Valeriano Della Longa on 2021/08/13.
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

final class GraphAcyclicSPTests: XCTestCase {
    var sut: GraphAcyclicSP<AdjacencyList<WeightedEdge<Double>>>!
    
    override func setUp() {
        super.setUp()
        
        whenGraphIsDAG()
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - When
    func whenGraphHasNoEdges() {
        let vertexCount = Int.random(in: 10..<100)
        let graph = AdjacencyList<WeightedEdge<Double>>(kind: .directed, vertexCount: vertexCount)
        let cycleUtil = GraphCycle(graph: graph)
        let source = (0..<vertexCount).randomElement()!
        sut = GraphAcyclicSP(cycleUtil, source: source)
    }
    
    func whenGraphIsDAG() {
        let vertexCount = Int.random(in: 10..<100)
        var edges: Array<WeightedEdge<Double>> = []
        for tail in 0..<(vertexCount / 2) {
            let weight = Double.random(in: -0.5...0.5)
            edges.append(WeightedEdge(tail: tail, head: tail + (vertexCount / 2), weight: weight))
        }
        let graph = AdjacencyList(kind: .directed, edges: edges)
        let cycleUtil = GraphCycle(graph: graph)
        let source = (0..<graph.vertexCount).randomElement()!
        assert(cycleUtil.topologicalSort != nil)
        sut = GraphAcyclicSP(cycleUtil, source: source)!
    }
    
    // MARK: - Tests
    func test_init_whenGraphCycleReturnsNonNilTopologicalSort_thenReturnsNewInstance() {
        let vertexCount = Int.random(in: 10..<100)
        var edges: Array<WeightedEdge<Double>> = []
        for tail in 0..<(vertexCount / 2) {
            let weight = Double.random(in: 0.5..<10.5)
            edges.append(WeightedEdge(tail: tail, head: tail + (vertexCount / 2), weight: weight))
        }
        let graph = AdjacencyList(kind: .directed, edges: edges)
        let cycleUtil = GraphCycle(graph: graph)
        let source = (0..<graph.vertexCount).randomElement()!
        
        sut = GraphAcyclicSP(cycleUtil, source: source)!
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.graph, graph)
        XCTAssertEqual(sut.source, source)
    }
    
    func testInit_whenGraphCycleReturnsNilTopologicalSort_thenReturnsNil() {
        let edges = givenRandomWeightedEdges()
        let graph = AdjacencyList<WeightedEdge<Double>>(kind: .undirected, edges: edges)
        let source = (0..<graph.vertexCount).randomElement()!
        let cycleUtil = GraphCycle(graph: graph)
        XCTAssertNil(GraphAcyclicSP(cycleUtil, source: source))
    }
    
    // MARK: - weight(to:) tests
    func testWeightTo_whenGraphHasNoEdges_thenReturnsNilForAnyDestinationVertexDifferentFromSource() {
        whenGraphHasNoEdges()
        for destination in 0..<sut.graph.vertexCount where destination != sut.source {
            XCTAssertNil(sut.weight(to: destination))
        }
    }
    
    func testWeightTo_whenSourceIsEqualToDestination_thenReturnsZero() {
        whenGraphHasNoEdges()
        XCTAssertEqual(sut.weight(to: sut.source), .zero)
        
        whenGraphIsDAG()
        XCTAssertEqual(sut.weight(to: sut.source), .zero)
    }
    
    func testWeightTo_whenGraphIsDAGAndDestinationIsDifferentThanSource_thenReturnsNilIfThereIsNoPathOtherwiseTotalWeightOfPath() {
        whenGraphIsDAG()
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
        
        whenGraphIsDAG()
        destination = sut.source
        XCTAssertTrue(sut.hasPath(to: destination))
    }
    
    func testHasPathTo_whenGraphIsDAG_thenReturnsTrueIfDestinationIsReachableFromSourceOtherWiseFalse() {
        whenGraphIsDAG()
        let reachablity = GraphReachability(graph: sut.graph, sources: [sut.source])
        for destination in 0..<sut.graph.vertexCount {
            XCTAssertEqual(sut.hasPath(to: destination), reachablity.isReachableFromSources(destination))
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
        
        whenGraphIsDAG()
        destination = sut.source
        path = sut.path(to: destination)
        for _ in path {
            XCTFail("path is not empty when destination is equal to source.")
            break
        }
    }
    
    func testPathTo_whenDestinationIsDifferentFromSourceAndHasPathToDestinationReturnsTrue_thenReturnsSequenceContainingEdgesFromSourceToDestination() {
        whenGraphIsDAG()
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
        whenGraphIsDAG()
        let allGraphVertices = (0..<sut.graph.vertexCount)
        allGraphVertices.forEach {
            let _ = sut.path(to: $0)
        }
        allGraphVertices.shuffled().forEach {
            let _ = sut.path(to: $0)
        }
    }
    
}
