//
//  AnyGraphTests.swift
//  Graph
//
//  Created by Valeriano Della Longa on 2021/05/04.
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

final class AnyGraphTests: XCTestCase {
    var sut: AnyGraph<WeightedEdge<Double>>!
    
    override func setUp() {
        super.setUp()
        
        let edges = givenRandomWeightedEdges()
        let kind = GraphConnections.allCases.randomElement()!
        let graph = DummyGraph<WeightedEdge<Double>>(kind: kind, edges: edges)
        sut = AnyGraph(graph)
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    func testInitConcrete() {
        let edges = givenRandomWeightedEdges()
        let kind = GraphConnections.allCases.randomElement()!
        let graph = DummyGraph<WeightedEdge<Double>>(kind: kind, edges: edges)
        sut = AnyGraph(graph)
        
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.kind, graph.kind)
        XCTAssertEqual(sut.vertexCount, graph.vertexCount)
        XCTAssertEqual(sut.edgeCount, graph.edgeCount)
        if sut.vertexCount == graph.vertexCount {
            for vertex in 0..<sut.vertexCount {
                XCTAssertEqual(sut.adjacencies(vertex: vertex), graph.adjacencies(vertex: vertex))
            }
        }
        let sutReversed = sut.reversed()
        let graphReversed = graph.reversed()
        for vertex in 0..<sutReversed.vertexCount {
            XCTAssertEqual(sutReversed.adjacencies(vertex: vertex), graphReversed.adjacencies(vertex: vertex))
        }
    }
    
    func testInitKindEdges() {
        let edges = givenRandomWeightedEdges()
        let kind = GraphConnections.allCases.randomElement()!
        let graph = AdjacencyList(kind: kind, edges: edges)
        sut = AnyGraph(kind: kind, edges: edges)
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.kind, graph.kind)
        XCTAssertEqual(sut.vertexCount, graph.vertexCount)
        XCTAssertEqual(sut.edgeCount, graph.edgeCount)
        if sut.vertexCount == graph.vertexCount {
            for vertex in 0..<sut.vertexCount {
                XCTAssertEqual(sut.adjacencies(vertex: vertex), graph.adjacencies(vertex: vertex))
            }
        }
        let sutReversed = sut.reversed()
        let graphReversed = graph.reversed()
        for vertex in 0..<sutReversed.vertexCount {
            XCTAssertEqual(sutReversed.adjacencies(vertex: vertex), graphReversed.adjacencies(vertex: vertex))
        }
    }
    
}
