//
//  GraphSCCTests.swift
//  GraphTests
//
//  Created by Valeriano Della Longa on 2021/05/17.
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

final class GraphSCCTests: XCTestCase {
    var sut: GraphStronglyConnectedComponents<AdjacencyList<WeightedEdge<Double>>>!
    
    override func setUp() {
        super.setUp()
        
        let edges = givenRandomWeightedEdges()
        let kind = GraphConnections.allCases.randomElement()!
        let graph = AdjacencyList(kind: kind, edges: edges)
        sut = GraphStronglyConnectedComponents(graph: graph)
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    func whenGraphHasNoEdges(kind: GraphConnections) {
        let vertexCount = Int.random(in: 10..<100)
        sut = GraphStronglyConnectedComponents(graph: AdjacencyList(kind: kind, vertexCount: vertexCount))
    }
    
    func whenGraphHas3SCC(kind: GraphConnections) {
        var edges = Array<WeightedEdge<Double>>()
        let vertexCount = Int.random(in: 10..<100)
        // We'll make three connected components, one for each third of vertices:
        for tail in 0..<(vertexCount - 1) where tail != (vertexCount / 3) && tail != ((vertexCount / 3 ) * 2) {
            let weight = Double.random(in: 0.5..<10.5)
            edges.append(WeightedEdge(tail: tail, head: tail + 1, weight: weight))
        }
        if kind == .directed {
            // We have to turn them into strongly connected components by adding
            // more edges that makes a cycle in every connected component:
            edges.append(WeightedEdge(tail: (vertexCount / 3), head: 0, weight: Double.random(in: 0.5..<10.5)))
            
            edges.append(WeightedEdge(tail: ((vertexCount / 3) * 2), head: ((vertexCount / 3) + 1), weight: Double.random(in: 0.5..<10.5)))
            
            edges.append(WeightedEdge(tail: vertexCount - 1, head: (((vertexCount / 3) * 2) + 1), weight: Double.random(in: 0.5..<10.5)))
        }
        let graph = AdjacencyList(kind: kind, edges: edges)
        sut = GraphStronglyConnectedComponents(graph: graph)
    }
    
    // MARK: - Tests
    func testInitGraph() {
        let edges = givenRandomWeightedEdges()
        let kind = GraphConnections.allCases.randomElement()!
        let graph = AdjacencyList(kind: kind, edges: edges)
        sut = GraphStronglyConnectedComponents(graph: graph)
        
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.graph, graph)
    }
    
    // MARK: - count tests
    func testCount_whenGraphHasNoEdges_thenReturnsSameValueOfGraphVertexCount() {
        whenGraphHasNoEdges(kind: .directed)
        XCTAssertEqual(sut.count, sut.graph.vertexCount)
        
        whenGraphHasNoEdges(kind: .undirected)
        XCTAssertEqual(sut.count, sut.graph.vertexCount)
    }
    
    func testCount_whenGraphHasEdgesAndThreeConnectedComponents() {
        whenGraphHas3SCC(kind: .directed)
        XCTAssertEqual(sut.count, 3)
        
        whenGraphHas3SCC(kind: .undirected)
        XCTAssertEqual(sut.count, 3)
    }
    
    // MARK: - areStronglyConnected(_:_:) tests
    func testAreStronglyConnected_whenGraphHasNoEdges_thenReturnsAlwaysFalseForDifferentVerticesAndTrueForSameVertices() {
        whenGraphHasNoEdges(kind: .directed)
        for v in 0..<sut.graph.vertexCount {
            for w in 0..<sut.graph.vertexCount {
                guard v != w else {
                    XCTAssertTrue(sut.areStronglyConnected(v, w))
                    
                    continue
                }
                XCTAssertFalse(sut.areStronglyConnected(v, w))
            }
        }
        
        whenGraphHasNoEdges(kind: .undirected)
        for v in 0..<sut.graph.vertexCount {
            for w in 0..<sut.graph.vertexCount {
                guard v != w else {
                    XCTAssertTrue(sut.areStronglyConnected(v, w))
                    
                    continue
                }
                XCTAssertFalse(sut.areStronglyConnected(v, w))
            }
        }
    }
    
    func testAreStronglyConnected_whenGraphHasThreeConnectedComponents_thenReturnsTrueForVerticesInSameComponentAndFalseWithVerticesFromDifferentComponents() {
        whenGraphHas3SCC(kind: .directed)
        var firstCRange = 0...(sut.graph.vertexCount / 3)
        var secondCRange = ((sut.graph.vertexCount / 3) + 1)...((sut.graph.vertexCount / 3) * 2)
        var thirdCRange = (((sut.graph.vertexCount / 3) * 2) + 1)..<sut.graph.vertexCount
        for v in firstCRange {
            for w in firstCRange {
                XCTAssertTrue(sut.areStronglyConnected(v, w))
                XCTAssertTrue(sut.areStronglyConnected(w, v))
            }
            for w in secondCRange {
                XCTAssertFalse(sut.areStronglyConnected(v, w))
                XCTAssertFalse(sut.areStronglyConnected(w, v))
            }
            for w in thirdCRange {
                XCTAssertFalse(sut.areStronglyConnected(v, w))
                XCTAssertFalse(sut.areStronglyConnected(w, v))
            }
        }
        for v in secondCRange {
            for w in firstCRange {
                XCTAssertFalse(sut.areStronglyConnected(v, w))
                XCTAssertFalse(sut.areStronglyConnected(w, v))
            }
            for w in secondCRange {
                XCTAssertTrue(sut.areStronglyConnected(v, w))
                XCTAssertTrue(sut.areStronglyConnected(w, v))
            }
            for w in thirdCRange {
                XCTAssertFalse(sut.areStronglyConnected(v, w))
                XCTAssertFalse(sut.areStronglyConnected(w, v))
            }
        }
        for v in thirdCRange {
            for w in firstCRange {
                XCTAssertFalse(sut.areStronglyConnected(v, w))
                XCTAssertFalse(sut.areStronglyConnected(w, v))
            }
            for w in secondCRange {
                XCTAssertFalse(sut.areStronglyConnected(v, w))
                XCTAssertFalse(sut.areStronglyConnected(w, v))
            }
            for w in thirdCRange {
                XCTAssertTrue(sut.areStronglyConnected(v, w))
                XCTAssertTrue(sut.areStronglyConnected(w, v))
            }
        }
        
        whenGraphHas3SCC(kind: .undirected)
        firstCRange = 0...(sut.graph.vertexCount / 3)
        secondCRange = ((sut.graph.vertexCount / 3) + 1)...((sut.graph.vertexCount / 3) * 2)
        thirdCRange = (((sut.graph.vertexCount / 3) * 2) + 1)..<sut.graph.vertexCount
        for v in firstCRange {
            for w in firstCRange {
                XCTAssertTrue(sut.areStronglyConnected(v, w))
                XCTAssertTrue(sut.areStronglyConnected(w, v))
            }
            for w in secondCRange {
                XCTAssertFalse(sut.areStronglyConnected(v, w))
                XCTAssertFalse(sut.areStronglyConnected(w, v))
            }
            for w in thirdCRange {
                XCTAssertFalse(sut.areStronglyConnected(v, w))
                XCTAssertFalse(sut.areStronglyConnected(w, v))
            }
        }
        for v in secondCRange {
            for w in firstCRange {
                XCTAssertFalse(sut.areStronglyConnected(v, w))
                XCTAssertFalse(sut.areStronglyConnected(w, v))
            }
            for w in secondCRange {
                XCTAssertTrue(sut.areStronglyConnected(v, w))
                XCTAssertTrue(sut.areStronglyConnected(w, v))
            }
            for w in thirdCRange {
                XCTAssertFalse(sut.areStronglyConnected(v, w))
                XCTAssertFalse(sut.areStronglyConnected(w, v))
            }
        }
        for v in thirdCRange {
            for w in firstCRange {
                XCTAssertFalse(sut.areStronglyConnected(v, w))
                XCTAssertFalse(sut.areStronglyConnected(w, v))
            }
            for w in secondCRange {
                XCTAssertFalse(sut.areStronglyConnected(v, w))
                XCTAssertFalse(sut.areStronglyConnected(w, v))
            }
            for w in thirdCRange {
                XCTAssertTrue(sut.areStronglyConnected(v, w))
                XCTAssertTrue(sut.areStronglyConnected(w, v))
            }
        }
    }
    
    // MARK: - id(of:) tests
    func testIDOf_whenGraphHasNoEdges() {
        whenGraphHasNoEdges(kind: .directed)
        var expectedID = 0
        for vertex in (0..<sut.graph.vertexCount).reversed() {
            XCTAssertEqual(sut.id(of: vertex), expectedID)
            expectedID += 1
        }
        
        whenGraphHasNoEdges(kind: .undirected)
        expectedID = 0
        for vertex in 0..<sut.graph.vertexCount {
            XCTAssertEqual(sut.id(of: vertex), expectedID)
            expectedID += 1
        }
    }
    
    func testIDOf_whenGraphHasThreeStronglyConnectedComponents() {
        whenGraphHas3SCC(kind: .directed)
        var firstCRange = 0...(sut.graph.vertexCount / 3)
        var secondCRange = ((sut.graph.vertexCount / 3) + 1)...((sut.graph.vertexCount / 3) * 2)
        for vertex in (0..<sut.graph.vertexCount) {
            let expectedResult: Int!
            if firstCRange ~= vertex {
                expectedResult = 2
            } else if secondCRange ~= vertex {
                expectedResult = 1
            } else {
                expectedResult = 0
            }
            XCTAssertEqual(sut.id(of: vertex), expectedResult)
        }
        
        whenGraphHas3SCC(kind: .undirected)
        firstCRange = 0...(sut.graph.vertexCount / 3)
        secondCRange = ((sut.graph.vertexCount / 3) + 1)...((sut.graph.vertexCount / 3) * 2)
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
    
    // MARK: - stronglyConnectedComponent(with:) tests
    func testStronglyConnectedComponentWith_whenGraphHasNoEdges_thenReturnsArrayWithJustOneVertex() {
        whenGraphHasNoEdges(kind: .directed)
        var expectedVertex = sut.graph.vertexCount - 1
        for id in 0..<sut.count {
            let component = sut.stronglyConnectedComponent(with: id)
            XCTAssertEqual(component.count, 1)
            XCTAssertEqual(component.first, expectedVertex)
            expectedVertex -= 1
        }
        
        whenGraphHasNoEdges(kind: .undirected)
        expectedVertex = 0
        for id in 0..<sut.count {
            let component = sut.stronglyConnectedComponent(with: id)
            XCTAssertEqual(component.count, 1)
            XCTAssertEqual(component.first, expectedVertex)
            expectedVertex += 1
        }
    }
    
    func testStronglyConnectedComponentWith_whenGraphHasThreeConnectedComponents() {
        whenGraphHas3SCC(kind: .directed)
        var expectedThirdComponent = Set(0...(sut.graph.vertexCount / 3))
        var expectedSecondComponent = Set(((sut.graph.vertexCount / 3) + 1)...((sut.graph.vertexCount / 3) * 2))
        var expectedFirstComponent = Set((((sut.graph.vertexCount / 3) * 2) + 1)..<sut.graph.vertexCount)
        XCTAssertEqual(Set(sut.stronglyConnectedComponent(with: 0)), expectedFirstComponent)
        XCTAssertEqual(Set(sut.stronglyConnectedComponent(with: 1)), expectedSecondComponent)
        XCTAssertEqual(Set(sut.stronglyConnectedComponent(with: 2)), expectedThirdComponent)
        
        whenGraphHas3SCC(kind: .undirected)
        expectedFirstComponent = Set(0...(sut.graph.vertexCount / 3))
        expectedSecondComponent = Set(((sut.graph.vertexCount / 3) + 1)...((sut.graph.vertexCount / 3) * 2))
        expectedThirdComponent = Set((((sut.graph.vertexCount / 3) * 2) + 1)..<sut.graph.vertexCount)
        XCTAssertEqual(Set(sut.stronglyConnectedComponent(with: 0)), expectedFirstComponent)
        XCTAssertEqual(Set(sut.stronglyConnectedComponent(with: 1)), expectedSecondComponent)
        XCTAssertEqual(Set(sut.stronglyConnectedComponent(with: 2)), expectedThirdComponent)
    }
    
    func testStronglyConnectedComponentWith_caching() {
        var expectedResult = Array<Array<Int>>(repeating: [], count: sut.count)
        for id in 0..<sut.count {
            let component = sut.stronglyConnectedComponent(with: id)
            expectedResult[id] = component
        }
        for id in 0..<sut.count {
            XCTAssertEqual(sut.stronglyConnectedComponent(with: id), expectedResult[id])
        }
    }
    
    // MARK: - verticesStronglyConnected(to:) tests
    func testVerticesStronglyConnectedTo_whenGraphHasNoEdge() {
        whenGraphHasNoEdges(kind: .directed)
        for vertex in 0..<sut.graph.vertexCount {
            let id = sut.id(of: vertex)
            let expectedResult = sut.stronglyConnectedComponent(with: id)
            XCTAssertEqual(sut.verticesStronglyConnected(to: vertex), expectedResult)
        }
        
        whenGraphHasNoEdges(kind: .undirected)
        for vertex in 0..<sut.graph.vertexCount {
            let id = sut.id(of: vertex)
            let expectedResult = sut.stronglyConnectedComponent(with: id)
            XCTAssertEqual(sut.verticesStronglyConnected(to: vertex), expectedResult)
        }
    }
    
    func testVerticesStronglyConnectedTo_whenGraphHasEdges() throws {
        try XCTSkipIf(sut.graph.edgeCount <= 0)
        for vertex in 0..<sut.graph.vertexCount {
            let id = sut.id(of: vertex)
            let expectedResult = sut.stronglyConnectedComponent(with: id)
            XCTAssertEqual(sut.verticesStronglyConnected(to: vertex), expectedResult)
        }
    }
    
}
