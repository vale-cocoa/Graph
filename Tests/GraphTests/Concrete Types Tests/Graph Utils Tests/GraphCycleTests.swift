//
//  GraphCycleTests.swift
//  GraphTests
//
//  Created by Valeriano Della Longa on 2021/05/13.
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

final class GraphCycleTests: XCTestCase {
    var sut: GraphCycle<AdjacencyList<WeightedEdge<Double>>>!
    
    override func setUp() {
        super.setUp()
        
        whenHasGraphHasNoVertex()
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - WHEN
    func whenHasGraphHasNoVertex() {
        let kind = GraphConnections.allCases.randomElement()!
        sut = GraphCycle(graph: AdjacencyList(kind: kind, vertexCount: 0))
    }
    
    func whenGraphHasNoEdges(kind: GraphConnections) {
        sut = GraphCycle(graph: AdjacencyList(kind: kind, vertexCount: Int.random(in: 10..<100)))
    }
    
    func whenGraphHasEdgesAndNoCycle(kind: GraphConnections) {
        let vertexCount = Int.random(in: 10..<100)
        var edges: Array<WeightedEdge<Double>> = []
        for tail in 0..<(vertexCount / 2) {
            let weight = Double.random(in: 0.5..<10.5)
            edges.append(WeightedEdge(tail: tail, head: tail + (vertexCount / 2), weight: weight))
        }
        
        let graph = AdjacencyList(kind: kind, edges: edges)
        sut = GraphCycle(graph: graph)
    }
    
    func whenGraphHasCycle(kind: GraphConnections) {
        let vertexCount = Int.random(in: 10..<100)
        var edges: Array<WeightedEdge<Double>> = []
        for tail in 0..<(vertexCount - 1) {
            let weight = Double.random(in: 0.5..<10.5)
            edges.append(WeightedEdge(tail: tail, head: tail + 1, weight: weight))
        }
        edges.append(WeightedEdge(tail: vertexCount - 1, head: 0, weight: 100.0))
        
        let graph = AdjacencyList(kind: kind, edges: edges)
        sut = GraphCycle(graph: graph)
    }
    
    // MARK: - Tests
    func testInitGraph() {
        let kind = GraphConnections.allCases.randomElement()!
        let edges = givenRandomWeightedEdges()
        let graph = AdjacencyList(kind: kind, edges: edges)
        sut = GraphCycle(graph: graph)
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.graph, graph)
    }
    
    // MARK: - cycle tests
    func testCycle_whenGraphHasNoVertex() {
        whenHasGraphHasNoVertex()
        XCTAssertTrue(sut.cycle.isEmpty)
    }
    
    func testCycle_whenGraphHasNoEdges() {
        whenGraphHasNoEdges(kind: .directed)
        XCTAssertTrue(sut.cycle.isEmpty)
        
        whenGraphHasNoEdges(kind: .undirected)
        XCTAssertTrue(sut.cycle.isEmpty)
    }
    
    func testCycle_whenGraphHasEdgesAndNoCycle() {
        whenGraphHasEdgesAndNoCycle(kind: .directed)
        XCTAssertTrue(sut.cycle.isEmpty)
        
        whenGraphHasEdgesAndNoCycle(kind: .undirected)
        XCTAssertTrue(sut.cycle.isEmpty)
    }
    
    func testCycle_whenGraphHasCycle() {
        whenGraphHasCycle(kind: .directed)
        XCTAssertEqual(sut.cycle, [sut.graph.vertexCount - 1, 0, sut.graph.vertexCount - 1])
        
        whenGraphHasCycle(kind: .undirected)
        XCTAssertEqual(sut.cycle, [sut.graph.vertexCount - 1, 0, sut.graph.vertexCount - 1])
    }
    
    // MARK: - hasCycle tests
    func testHasCycle_whenGraphHasNoVertex() {
        whenHasGraphHasNoVertex()
        XCTAssertFalse(sut.hasCycle)
    }
    
    func testHasCycle_whenGraphHasNoEdges() {
        whenGraphHasNoEdges(kind: .directed)
        XCTAssertFalse(sut.hasCycle)
        
        whenGraphHasNoEdges(kind: .undirected)
        XCTAssertFalse(sut.hasCycle)
    }
    
    func testHasCycle_whenGraphHasEdgesWithNoCycle() {
        whenGraphHasEdgesAndNoCycle(kind: .directed)
        XCTAssertFalse(sut.hasCycle)
        
        whenGraphHasEdgesAndNoCycle(kind: .undirected)
        XCTAssertFalse(sut.hasCycle)
    }
    
    func testHasCycle_whenGraphHasCycle() {
        whenGraphHasCycle(kind: .directed)
        XCTAssertTrue(sut.hasCycle)
        
        whenGraphHasCycle(kind: .undirected)
        XCTAssertTrue(sut.hasCycle)
    }
    
    // MARK: - topologicalSort tests
    func testTopologicalSort_whenGraphHasNoVertex() {
        whenHasGraphHasNoVertex()
        if sut.graph.kind == .directed {
            XCTAssertEqual(sut.topologicalSort, [])
        } else {
            XCTAssertNil(sut.topologicalSort)
        }
    }
    
    func testTopologicalSort_whenGraphHasEdgesWithNoCycle() {
        whenGraphHasEdgesAndNoCycle(kind: .directed)
        var expectedTopologicalSort = [Int]()
        let vCount = sut.graph.vertexCount
        for i in 0..<(vCount / 2) {
            expectedTopologicalSort.append((vCount / 2) - 1 - i)
            expectedTopologicalSort.append(vCount - 1 - i)
        }
        XCTAssertEqual(sut.topologicalSort, expectedTopologicalSort)
        
        whenGraphHasEdgesAndNoCycle(kind: .undirected)
        XCTAssertNil(sut.topologicalSort)
    }
    
    func testTopologicalSort_whenGraphHasCycle() {
        whenGraphHasCycle(kind: .directed)
        XCTAssertNil(sut.topologicalSort)
        
        whenGraphHasCycle(kind: .undirected)
        XCTAssertNil(sut.topologicalSort)
    }
    
}
