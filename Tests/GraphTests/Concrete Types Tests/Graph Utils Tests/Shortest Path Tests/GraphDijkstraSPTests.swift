//
//  GraphDijkstraSPTests.swift
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

final class GraphDijkstraSPTests: XCTestCase {
    var sut: GraphDijkstraSP<AdjacencyList<WeightedEdge<Double>>>!
    
    override func setUp() {
        super.setUp()
        
        whenGraphHasEdgesWithPositiveWeights()
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - When
    func whenGraphHasNoEdges() {
        let vCount = Int.random(in: 10..<100)
        let graph = AdjacencyList<WeightedEdge<Double>>(kind: .allCases.randomElement()!, vertexCount: vCount)
        let source = (0..<vCount).randomElement()!
        sut = GraphDijkstraSP(graph: graph, source: source)
    }
    
    func whenGraphHasEdgesWithPositiveWeights() {
        let edges = givenRandomWeightedEdges()
        let graph = AdjacencyList(kind: .allCases.randomElement()!, edges: edges)
        let source = (0..<graph.vertexCount).randomElement()!
        sut = GraphDijkstraSP(graph: graph, source: source)
    }
    
    func whenBuildingShortestPathsEncountersAnEdgeWithNegativeWeight() {
        var edges = givenRandomWeightedEdges()
        let maxCountOfNegativeEdges = Int.random(in: 1..<edges.count)
        for _ in 0..<maxCountOfNegativeEdges {
            let i = edges.indices.randomElement()!
            guard
                edges[i].weight > .zero
            else { continue }
            
            edges[i].weight *= -(1.0)
        }
        let graph = AdjacencyList(kind: .allCases.randomElement()!, edges: edges)
        let source = edges.filter({ $0.weight < .zero }).shuffled().first!.tail
        sut = GraphDijkstraSP(graph: graph, source: source)
    }
    
    // MARK: - Tests
    func testInit() {
        let edges = givenRandomWeightedEdges()
        let graph = AdjacencyList(kind: .allCases.randomElement()!, edges: edges)
        let source = (0..<graph.vertexCount).randomElement()!
        
        sut = GraphDijkstraSP(graph: graph, source: source)
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.graph, graph)
        XCTAssertEqual(sut.source, source)
    }
    
    // MARK: - weight(to:) tests
    func testWeightTo_whenGraphHasNoEdgesAndDestinationIsDifferentFromSource_thenDoesntThrowAndReturnsNilForEveryDestinationVertex() {
        whenGraphHasNoEdges()
        for destination in 0..<sut.graph.vertexCount where destination != sut.source {
            do {
                let result = try sut.weight(to: destination)
                XCTAssertNil(result)
            } catch {
                XCTFail("Has thrown error")
            }
        }
    }
    
    func testWeightTo_whenDestinationIsEqualToSourceAndNoNegativeWeightedEdgesWereDiscovered_thenDoesntThrowAndReturnsZero() {
        whenGraphHasNoEdges()
        var destination = sut.source
        do {
            let result = try sut.weight(to: destination)
            XCTAssertEqual(result, .zero)
        } catch {
            XCTFail("Has thrown error")
        }
        
        whenGraphHasEdgesWithPositiveWeights()
        destination = sut.source
        do {
            let result = try sut.weight(to: destination)
            XCTAssertEqual(result, .zero)
        } catch {
            XCTFail("Has thrown error")
        }
    }
    
    func testWeightTo_whenGraphHasEdgesWithPositiveWeightsAndDestinationIsDifferentThanSource_thenDoesntThrowAndReturnsNilIfThereIsNoPathOtherwiseSumOfWeightsOfEdgesOnPath() {
        whenGraphHasEdgesWithPositiveWeights()
        for destination in 0..<sut.graph.vertexCount where destination != sut.source {
            do {
                let expectedResult: Double? = try sut.path(to: destination)
                    .reduce(nil, { partial, edge in
                        guard
                            let partial = partial
                        else { return edge.weight }
                        
                        return partial + edge.weight
                    })
                let result = try sut.weight(to: destination)
                XCTAssertEqual(result, expectedResult)
            } catch {
                XCTFail("Has thrown error for destination: \(destination)")
            }
        }
    }
    
    func testWeightTo_whenBuildingShortestPathsEncountersAnEdgeWithNegativeWeight_thenAlwaysThrows() {
        whenBuildingShortestPathsEncountersAnEdgeWithNegativeWeight()
        for destination in 0..<sut.graph.vertexCount {
            XCTAssertThrowsError(try sut.weight(to: destination))
        }
    }
    
    // MARK: - hasPath(to:) tests
    func testHasPathTo_whenGraphHasNoEdges_thenDoesntThrowAndReturnsFalseForEveryDestinationVertexDifferentFromSource() {
        whenGraphHasNoEdges()
        for destination in 0..<sut.graph.vertexCount where destination != sut.source {
            do {
                let result = try sut.hasPath(to: destination)
                XCTAssertFalse(result)
            } catch {
                XCTFail("Has thrown error")
            }
        }
    }
    
    func testHasPathTo_whenDestinationIsEqualToSourceAndNoNegativeWeightedEdgesWereDiscovered_thenDoesntThrowAndReturnsTrue() {
        whenGraphHasNoEdges()
        var destination = sut.source
        do {
            let result = try sut.hasPath(to: destination)
            XCTAssertTrue(result)
        } catch {
            XCTFail("Has thrown error")
        }
        
        whenGraphHasEdgesWithPositiveWeights()
        destination = sut.source
        do {
            let result = try sut.hasPath(to: destination)
            XCTAssertTrue(result)
        } catch {
            XCTFail("Has thrown error")
        }
    }
    
    func testHasPathTo_whenGraphHasEdgesWithPositiceWeights_thenDoesntThrowAndReturnsReturnsTrueIfDestinationIsReachableFromSourceOtherWiseFalse() {
        whenGraphHasEdgesWithPositiveWeights()
        let reachability = GraphReachability(graph: sut.graph, sources: [sut.source])
        for destination in 0..<sut.graph.vertexCount {
            do {
                let result = try sut.hasPath(to: destination)
                XCTAssertEqual(result, reachability.isReachableFromSources(destination))
            } catch {
                XCTFail("Has thrown error")
            }
            
        }
    }
    
    func testHasPathTo_whenBuildingShortestPathsEncountersAnEdgeWithNegativeWeight_thenAlwaysThrows() {
        whenBuildingShortestPathsEncountersAnEdgeWithNegativeWeight()
        for destination in 0..<sut.graph.vertexCount {
            XCTAssertThrowsError(try sut.hasPath(to: destination))
        }
    }
    
    // MARK: - path(to:) tests
    func testPathTo_whenGraphHasNoEdges_thenDoesntThrowAndReturnsEmptySequence() {
        whenGraphHasNoEdges()
        Outer: for destination in 0..<sut.graph.vertexCount {
            do {
                let result = try sut.path(to: destination)
                for _ in result {
                    XCTFail("path is not empty for destination: \(destination)")
                    continue Outer
                }
            } catch {
                XCTFail("Has thrown error")
            }
        }
    }
    
    func testPathTo_whenGraphHasEdgesWithPositiveWeightsAndDestinationIsDifferentThanSourceAndHasPathToDestinationIsTrue_thenDoesntThrowAndReturnsSequenceContainingEdgesFromSourceToDestination() {
        whenGraphHasEdgesWithPositiveWeights()
        for destination in 0..<sut.graph.vertexCount where destination != sut.source {
            do {
                guard
                    try sut.hasPath(to: destination)
                else { continue }
                
                let path = try sut.path(to: destination)
                var pathDest = sut.source
                for edge in path {
                    pathDest = edge.other(pathDest)
                }
                XCTAssertEqual(pathDest, destination)
            } catch {
                XCTFail("Has thrown error")
            }
        }
    }
    
    func testPathTo_whenBuildingShortestPathsEncountersAnEdgeWithNegativeWeight_thenAlwaysThrows() {
        whenBuildingShortestPathsEncountersAnEdgeWithNegativeWeight()
        for destination in 0..<sut.graph.vertexCount {
            XCTAssertThrowsError(try sut.path(to: destination))
        }
    }
    
    func testPathTo_memoization() {
        whenGraphHasEdgesWithPositiveWeights()
        let allGraphVertices = (0..<sut.graph.vertexCount)
        do {
            try allGraphVertices.forEach {
                let _ = try sut.path(to: $0)
            }
            try allGraphVertices.shuffled().forEach {
                let _ = try sut.path(to: $0)
            }
        } catch {
            XCTFail("Has thrown error")
        }
    }
    
}
