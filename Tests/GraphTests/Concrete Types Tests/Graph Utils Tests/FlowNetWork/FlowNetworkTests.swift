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
    
    // MARK: - Tests
    func testInit_whenGraphHasNoEdges_thenDoesntThrowAndReturnsFlowNetworkInstance() {
        let graph = G(kind: .allCases.randomElement()!, vertexCount: Int.random(in: 10..<100))
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
        let edges = givenRandomWeightedEdges()
        let graph = G(kind: .allCases.randomElement()!, edges: edges)
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
        var edges = givenRandomWeightedEdges()
        let countOfNegativeWeights = Int.random(in: 1..<edges.count)
        for _ in 0..<countOfNegativeWeights {
            let i = edges.indices.randomElement()!
            edges[i].weight = Double.random(in: -1.0..<Double.zero)
        }
        let graph = G(kind: .allCases.randomElement()!, edges: edges)
        let s = Int.random(in: 0..<graph.vertexCount)
        let t = Int.random(in: 0..<graph.vertexCount)
        do {
            let _ = try FlowNetwork(graph, s: s, t: t)
            XCTFail("Has not thrown error")
        } catch {
            XCTAssertEqual(error as NSError, FlowNetwork<G>.Error.negativeWeightedEdge as NSError)
        }
    }
    
    
    
}
