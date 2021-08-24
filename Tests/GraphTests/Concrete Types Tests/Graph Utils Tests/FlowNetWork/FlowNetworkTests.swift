//
//  FlowNetworkTests.swift
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

final class FlowNetworkTests: XCTestCase {
    typealias G = AdjacencyList<WeightedEdge<Double>>
    
    typealias Edge = G.Edge
    
    typealias FlowEdge = FlowNetwork<G>.FlowEdge
    
    var sut: FlowNetwork<G>!
    
    override func setUp() {
        super.setUp()
        
        let edges = givenRandomWeightedEdges()
        let graph = G(kind: .allCases.randomElement()!, edges: edges)
        let s = (0..<graph.vertexCount).randomElement()!
        let t = (0..<graph.vertexCount).randomElement()!
        sut = try? FlowNetwork(graph, s: s, t: t)
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - given
    func givenGraphWithNoEdges(kind: GraphConnections) -> G {
        let vertexCount = Int.random(in: 10..<100)
        
        return G(kind: kind, vertexCount: vertexCount)
    }
    
    func givenGraphWithNonNegativeWeights(kind: GraphConnections) -> G {
        let edges = givenRandomWeightedEdges()
        
        return G(kind: kind, edges: edges)
    }
    
    func givenGraphWithSomeEdgesWithNegativeWeight(kind: GraphConnections) -> G {
        var edges = givenRandomWeightedEdges()
        let countOfNegativeWeights = Int.random(in: 1..<edges.count)
        for _ in 0..<countOfNegativeWeights {
            let i = edges.indices.randomElement()!
            edges[i].weight = Double.random(in: -1.0..<Double.zero)
        }
        
        return G(kind: kind, edges: edges)
    }
    
    // MARK: - When
    func whenGraphHasNoEdgesAndSIsDifferentThanT() {
        let graph = givenGraphWithNoEdges(kind: .allCases.randomElement()!)
        let s = Int.random(in: 0..<graph.vertexCount)
        var t: Int!
        repeat {
            t = Int.random(in: 0..<graph.vertexCount)
        } while t == s
        sut = try! FlowNetwork(graph, s: s, t: t)
    }
    
    func whenSAndTAreSameVertex(graphKind: GraphConnections, graphHasEdges: Bool) {
        let graph = graphHasEdges ? givenGraphWithNonNegativeWeights(kind: graphKind) : givenGraphWithNoEdges(kind: graphKind)
        let s = Int.random(in: 0..<graph.vertexCount)
        sut = try! FlowNetwork(graph, s: s, t: s)
    }
    
    func whenSAndTAreDifferentAndNotConnected() throws {
        for _ in 0..<10 {
            let graph = givenGraphWithNonNegativeWeights(kind: .allCases.randomElement()!)
            let allVertices = 0..<graph.vertexCount
            let s = Int.random(in: allVertices)
            let verticesConnectedToS = graph.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: s, { _ in })
            let verticesNotConnectedToS = Set(allVertices).subtracting(verticesConnectedToS)
            guard
                let t = verticesNotConnectedToS.randomElement()
            else { continue }
            
            sut = try! FlowNetwork(graph, s: s, t: t)
            return
        }
        throw XCTSkip()
    }
    
    func whenSAndTAreDifferentAndConnected(graphKind: GraphConnections) throws {
        for _ in 0..<10 {
            let graph = givenGraphWithNonNegativeWeights(kind: graphKind)
            let cc = GraphStronglyConnectedComponents(graph: graph)
            Inner: for id in 0..<cc.count {
                let candidate = cc.stronglyConnectedComponent(with: id)
                guard
                    candidate.count >= 3
                else { continue Inner }
                
                let s = candidate.first!
                let t = candidate.last!
                sut = try! FlowNetwork(graph, s: s, t: t)
                return
            }
        }
        throw XCTSkip()
    }
    
    func whenBadCaseScenario() {
        // This is a worst case scenario for the Ford-Fulkerson algorithm
        var edges: [WeightedEdge<Double>] = []
        edges.append(WeightedEdge(tail: 0, head: 1, weight: 100.0))
        edges.append(WeightedEdge(tail: 0, head: 2, weight: 100.0))
        edges.append(WeightedEdge(tail: 1, head: 2, weight: 1.0))
        edges.append(WeightedEdge(tail: 1, head: 3, weight: 100.0))
        edges.append(WeightedEdge(tail: 2, head: 3, weight: 100.0))
        let graph = G(kind: .directed, edges: edges)
        sut = try! FlowNetwork(graph, s: 0, t: 3)
    }
    
    func whenKnownFlowNetwork() {
        // This is a known scenario for testing Ford-Fulkerson algorithm
        var edges: [WeightedEdge<Double>] = []
        edges.append(WeightedEdge(tail: 0, head: 1, weight: 10.0))
        edges.append(WeightedEdge(tail: 0, head: 2, weight: 5.0))
        edges.append(WeightedEdge(tail: 0, head: 3, weight: 15.0))
        edges.append(WeightedEdge(tail: 1, head: 2, weight: 4.0))
        edges.append(WeightedEdge(tail: 1, head: 4, weight: 9.0))
        edges.append(WeightedEdge(tail: 1, head: 5, weight: 15.0))
        edges.append(WeightedEdge(tail: 2, head: 3, weight: 4.0))
        edges.append(WeightedEdge(tail: 2, head: 5, weight: 8.0))
        edges.append(WeightedEdge(tail: 3, head: 6, weight: 16.0))
        edges.append(WeightedEdge(tail: 4, head: 7, weight: 10.0))
        edges.append(WeightedEdge(tail: 4, head: 5, weight: 15.0))
        edges.append(WeightedEdge(tail: 5, head: 6, weight: 15.0))
        edges.append(WeightedEdge(tail: 5, head: 7, weight: 10.0))
        edges.append(WeightedEdge(tail: 6, head: 2, weight: 6.0))
        edges.append(WeightedEdge(tail: 6, head: 7, weight: 10.0))
        
        let graph = G(kind: .directed, edges: edges)
        sut = try! FlowNetwork(graph, s: 0, t: 7)
    }
    
    // MARK: - Tests
    func testInit_whenGraphHasNoEdges_thenDoesntThrowAndReturnsFlowNetworkInstance() {
        let graph = givenGraphWithNoEdges(kind: .allCases.randomElement()!)
        let s = Int.random(in: 0..<graph.vertexCount)
        let t = Int.random(in: 0..<graph.vertexCount)
        XCTAssertNoThrow(sut = try FlowNetwork(graph, s: s, t: t))
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.graph, graph)
        XCTAssertEqual(sut.s, s)
        XCTAssertEqual(sut.t, t)
        XCTAssertEqual(sut.vertexCount, graph.vertexCount)
        XCTAssertEqual(sut.flowEdgeCount, 0)
    }
    
    func testInit_whenGraphHasEdgesWithNonNegativeWeightValues_thenDoesntThrowAndReturnsFlowNetworkInstance() {
        let graph = givenGraphWithNonNegativeWeights(kind: .allCases.randomElement()!)
        let s = Int.random(in: 0..<graph.vertexCount)
        let t = Int.random(in: 0..<graph.vertexCount)
        XCTAssertNoThrow(sut = try FlowNetwork(graph, s: s, t: t))
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.graph, graph)
        XCTAssertEqual(sut.s, s)
        XCTAssertEqual(sut.t, t)
        XCTAssertEqual(sut.vertexCount, graph.vertexCount)
        let expectedFlowEdgesCount = graph.kind == .undirected ? graph.edgeCount * 4 : graph.edgeCount * 2
        XCTAssertGreaterThanOrEqual(sut.flowEdgeCount, expectedFlowEdgesCount)
    }
    
    func testInit_whenGraphHasEdgesAndSomeEdgeHasNegativeWeightValue_thenThrows() {
        let graph = givenGraphWithSomeEdgesWithNegativeWeight(kind: .allCases.randomElement()!)
        let s = Int.random(in: 0..<graph.vertexCount)
        let t = Int.random(in: 0..<graph.vertexCount)
        do {
            let _ = try FlowNetwork(graph, s: s, t: t)
            XCTFail("Has not thrown error")
        } catch {
            XCTAssertEqual(error as NSError, FlowNetwork<G>.Error.negativeWeightedEdge as NSError)
        }
    }
    
    // MARK: - maxFlow tests
    func testMaxFlow_whenGraphHasNoEdgesAndSIsDifferentThanT_returnsZero() {
        whenGraphHasNoEdgesAndSIsDifferentThanT()
        XCTAssertEqual(sut.maxFlow, .zero)
    }
    
    func testMaxFlow_whenSAndTAreSameVertex_thenReturnsNil() {
        // graph has no edge
        whenSAndTAreSameVertex(graphKind: .allCases.randomElement()!, graphHasEdges: false)
        XCTAssertNil(sut.maxFlow)
        
        // graph has edges
        whenSAndTAreSameVertex(graphKind: .allCases.randomElement()!, graphHasEdges: true)
        XCTAssertNil(sut.maxFlow)
    }
    
    func testMaxFlow_whenSAndTAreDifferentAndNotConnected_thenReturnsZero() throws {
        try whenSAndTAreDifferentAndNotConnected()
        XCTAssertEqual(sut.maxFlow, .zero)
        let flowEdgesIncidentToT = sut.flowedAdjacencies(for: sut.t).filter({ $0.to == sut.t })
        let expectedMaxFlow: Double = flowEdgesIncidentToT.reduce(.zero, { $0 + $1.flow })
        XCTAssertEqual(expectedMaxFlow, .zero)
    }
    
    func testMaxFlow_whenSAndTAreDifferentAndConnected_thenReturnsValueGreaterThanZero() throws {
        try whenSAndTAreDifferentAndConnected(graphKind: .allCases.randomElement()!)
        guard
            let result = sut.maxFlow
        else {
            XCTFail("Returned nil")
            return
        }
        
        XCTAssertGreaterThan(result, .zero)
        let flowEdgesIncidentToT = sut.flowedAdjacencies(for: sut.t).filter({ $0.to == sut.t })
        let expectedMaxFlow: Double = flowEdgesIncidentToT.reduce(.zero, { $0 + $1.flow })
        XCTAssertEqual(result, expectedMaxFlow)
    }
    
    func testMaxFlow_whenSAndTAreDifferentAndConnectedAndGraphIsDirected_thenResultIsSameOfFlowNetworkBuiltWithReversedGraphAndInvertedSAndTVertices() throws {
        try whenSAndTAreDifferentAndConnected(graphKind: .directed)
        let expectedResult = sut.maxFlow
        let s = sut.s
        let t = sut.t
        let reversededGraph = sut.graph.reversed()
        
        let reversedFlowNetwork = try! FlowNetwork(reversededGraph, s: t, t: s)
        XCTAssertEqual(reversedFlowNetwork.maxFlow, expectedResult)
    }
    
    func testMinCutFlowIsEqualToMaxFlow() throws {
        try whenSAndTAreDifferentAndConnected(graphKind: .allCases.randomElement()!)
        let expectedResult = sut.maxFlow
        let result = sut.minCut.reduce(.zero, { $0 + $1.flow })
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_withBadCaseScenario() {
        whenBadCaseScenario()
        XCTAssertEqual(sut.maxFlow, 200.0)
        XCTAssertTrue(sut.inMinCut(0))
        
        for vertex in 1..<4 {
            XCTAssertFalse(sut.inMinCut(vertex))
        }
        let flowEdgesIncidentToT = sut.flowedAdjacencies(for: sut.t).filter({ $0.to == sut.t })
        let result: Double = flowEdgesIncidentToT.reduce(.zero, { $0 + $1.flow })
        XCTAssertEqual(result, sut.maxFlow)
    }
    
    func test_withKnownFlowNetwork() {
        whenKnownFlowNetwork()
        XCTAssertEqual(sut.maxFlow, 28.0)
        let expectedVerticesInMinCut: Set<Int> = [0, 2, 3, 6]
        for vertex in 0..<sut.graph.vertexCount {
            if expectedVerticesInMinCut.contains(vertex) {
                XCTAssertTrue(sut.inMinCut(vertex))
            } else {
                XCTAssertFalse(sut.inMinCut(vertex))
            }
        }
        let flowEdgesIncidentToT = sut.flowedAdjacencies(for: sut.t).filter({ $0.to == sut.t })
        let result: Double = flowEdgesIncidentToT.reduce(.zero, { $0 + $1.flow })
        XCTAssertEqual(result, sut.maxFlow)
    }
    
}
