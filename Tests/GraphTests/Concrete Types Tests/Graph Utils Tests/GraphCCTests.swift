//
//  GraphCCTests.swift
//  GraphTests
//
//  Created by Valeriano Della Longa on 2021/05/12.
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

final class GraphCCTests: XCTestCase {
    var sut: GraphConnectedComponents<AdjacencyList<WeightedEdge<Double>>>!
    
    override func setUp() {
        super.setUp()
        
        let edges = givenRandomWeightedEdges()
        let kind = GraphConnections.allCases.randomElement()!
        let graph = AdjacencyList(kind: kind, edges: edges)
        sut = GraphConnectedComponents(graph: graph)
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - WHEN
    func whenGraphHasNoEdges() {
        let vertexCount = Int.random(in: 10..<100)
        let kind = GraphConnections.allCases.randomElement()!
        sut = GraphConnectedComponents(graph: AdjacencyList(kind: kind, vertexCount: vertexCount))
    }
    
    
    func whenGraphHasEdgesAndThreeConnectedComponents() {
        var edges = Array<WeightedEdge<Double>>()
        let vertexCount = Int.random(in: 10..<100)
        // We'll make three connected components, one for each third of vertices:
        for tail in 0..<(vertexCount - 1) where tail != (vertexCount / 3) && tail != ((vertexCount / 3 ) * 2) {
            let weight = Double.random(in: 0.5..<10.5)
            edges.append(WeightedEdge(tail: tail, head: tail + 1, weight: weight))
        }
        let kind = GraphConnections.allCases.randomElement()!
        sut = GraphConnectedComponents(graph: AdjacencyList(kind: kind, edges: edges))
    }
    
    // MARK: - Tests
    func testInitGraph() {
        let edges = givenRandomWeightedEdges()
        let kind = GraphConnections.allCases.randomElement()!
        let graph = AdjacencyList(kind: kind, edges: edges)
        sut = GraphConnectedComponents(graph: graph)
        
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.graph, graph)
    }
    
    // MARK: - count tests
    func testCount_whenGraphHasNoEdges_thenReturnsSameValueOfGraphVertexCount() {
        whenGraphHasNoEdges()
        XCTAssertEqual(sut.count, sut.graph.vertexCount)
    }
    
    func testCount_whenGraphHasEdgesAndThreeConnectedComponents() {
        whenGraphHasEdgesAndThreeConnectedComponents()
        XCTAssertEqual(sut.count, 3)
    }
    
    // MARK: - areConnected(_:_:) tests
    func testAreConnected_whenGraphHasNoEdges_thenReturnsAlwaysFalseForDifferentVerticesAndTrueForSameVertices() {
        whenGraphHasNoEdges()
        for v in 0..<sut.graph.vertexCount {
            for w in 0..<sut.graph.vertexCount {
                guard v != w else {
                    XCTAssertTrue(sut.areConnected(v, w))
                    
                    continue
                }
                XCTAssertFalse(sut.areConnected(v, w))
            }
        }
    }
    
    func testAreConnected_whenGraphHasEdgesAndThreeConnectedComponents_thenReturnsTrueForVerticesInSameComponentAndFalseWithVerticesFromDifferentComponents() {
        whenGraphHasEdgesAndThreeConnectedComponents()
        let firstCRange = 0...(sut.graph.vertexCount / 3)
        let secondCRange = ((sut.graph.vertexCount / 3) + 1)...((sut.graph.vertexCount / 3) * 2)
        let thirdCRange = (((sut.graph.vertexCount / 3) * 2) + 1)..<sut.graph.vertexCount
        for v in firstCRange {
            for w in firstCRange {
                XCTAssertTrue(sut.areConnected(v, w))
                XCTAssertTrue(sut.areConnected(w, v))
            }
            for w in secondCRange {
                XCTAssertFalse(sut.areConnected(v, w))
                XCTAssertFalse(sut.areConnected(w, v))
            }
            for w in thirdCRange {
                XCTAssertFalse(sut.areConnected(v, w))
                XCTAssertFalse(sut.areConnected(w, v))
            }
        }
        
        for v in secondCRange {
            for w in firstCRange {
                XCTAssertFalse(sut.areConnected(v, w))
                XCTAssertFalse(sut.areConnected(w, v))
            }
            for w in secondCRange {
                XCTAssertTrue(sut.areConnected(v, w))
                XCTAssertTrue(sut.areConnected(w, v))
            }
            for w in thirdCRange {
                XCTAssertFalse(sut.areConnected(v, w))
                XCTAssertFalse(sut.areConnected(w, v))
            }
        }
        
        for v in thirdCRange {
            for w in firstCRange {
                XCTAssertFalse(sut.areConnected(v, w))
                XCTAssertFalse(sut.areConnected(w, v))
            }
            for w in secondCRange {
                XCTAssertFalse(sut.areConnected(v, w))
                XCTAssertFalse(sut.areConnected(w, v))
            }
            for w in thirdCRange {
                XCTAssertTrue(sut.areConnected(v, w))
                XCTAssertTrue(sut.areConnected(w, v))
            }
        }
        
    }
    
    // MARK: - id(of:) tests
    func testIDOf_whenGraphHasNoEdges() {
        whenGraphHasNoEdges()
        var expectedID = 0
        for vertex in 0..<sut.graph.vertexCount {
            XCTAssertEqual(sut.id(of: vertex), expectedID)
            expectedID += 1
        }
    }
    
    func testIDOf_whenGraphHasEdgesAndThreeConnectedComponents() {
        whenGraphHasEdgesAndThreeConnectedComponents()
        let firstCRange = 0...(sut.graph.vertexCount / 3)
        let secondCRange = ((sut.graph.vertexCount / 3) + 1)...((sut.graph.vertexCount / 3) * 2)
        for vertex in 0..<sut.graph.vertexCount {
            let expectedResult: Int!
            if firstCRange ~= vertex {
                expectedResult = 0
            } else if secondCRange ~= vertex {
                expectedResult = 1
            } else {
                expectedResult = 2
            }
            XCTAssertEqual(sut.id(of: vertex), expectedResult)
        }
    }
    
    // MARK: - component(with:) tests
    func testComponentWith_whenGraphHasNoEdges_thenReturnsArrayWithJustOneVertex() {
        whenGraphHasNoEdges()
        var expectedVertex = 0
        for id in 0..<sut.count {
            let component = sut.component(with: id)
            XCTAssertEqual(component.count, 1)
            XCTAssertEqual(component.first, expectedVertex)
            expectedVertex += 1
        }
    }
    
    func testComponentWith_whenGraphHasEdgesAndThreeConnectedComponents() {
        whenGraphHasEdgesAndThreeConnectedComponents()
        let expectedFirstComponent = Set(0...(sut.graph.vertexCount / 3))
        let expectedSecondComponent = Set(((sut.graph.vertexCount / 3) + 1)...((sut.graph.vertexCount / 3) * 2))
        let expectedThirdComponent = Set((((sut.graph.vertexCount / 3) * 2) + 1)..<sut.graph.vertexCount)
        XCTAssertEqual(Set(sut.component(with: 0)), expectedFirstComponent)
        XCTAssertEqual(Set(sut.component(with: 1)), expectedSecondComponent)
        XCTAssertEqual(Set(sut.component(with: 2)), expectedThirdComponent)
        
    }
    
    func testComponentWith_caching() {
        var expectedResult = Array<Array<Int>>(repeating: [], count: sut.count)
        for id in 0..<sut.count {
            let component = sut.component(with: id)
            expectedResult[id] = component
        }
        for id in 0..<sut.count {
            XCTAssertEqual(sut.component(with: id), expectedResult[id])
        }
    }
    
    // MARK: - verticesConnected(to:) tests
    func testVerticesConnectedTo_whenGraphHasNoEdge() {
        whenGraphHasNoEdges()
        for vertex in 0..<sut.graph.vertexCount {
            let id = sut.id(of: vertex)
            let expectedResult = sut.component(with: id)
            XCTAssertEqual(sut.verticesConnected(to: vertex), expectedResult)
        }
    }
    
    func testVerticesConnectedTo_whenGraphHasEdges() throws {
        try XCTSkipIf(sut.graph.edgeCount <= 0)
        for vertex in 0..<sut.graph.vertexCount {
            let id = sut.id(of: vertex)
            let expectedResult = sut.component(with: id)
            XCTAssertEqual(sut.verticesConnected(to: vertex), expectedResult)
        }
    }
    
}
