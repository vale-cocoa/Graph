//
//  GraphDegreesTests.swift
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

final class GraphDegreesTests: XCTestCase {
    var sut: GraphDegrees<AdjacencyList<WeightedEdge<Double>>>!
    
    override func setUp() {
        super.setUp()
        
        whenGraphHasNoVertices()
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - When
    func whenGraphHasNoVertices() {
        let kind = GraphConnections.allCases.randomElement()!
        sut = GraphDegrees(graph: AdjacencyList(kind: kind, vertexCount: 0))
    }
    
    func whenGraphHasNoEdges(kind: GraphConnections) {
        let vertexCount = Int.random(in: 10..<100)
        sut = GraphDegrees(graph: AdjacencyList(kind: kind, vertexCount: vertexCount))
    }
    
    func whenGraphHasEdges(kind: GraphConnections) {
        let edges = givenRandomWeightedEdges()
        let graph = AdjacencyList(kind: kind, edges: edges)
        sut = GraphDegrees(graph: graph)
    }
    
    // MARK: - Tests
    func testInitGraph() {
        let kind = GraphConnections.allCases.randomElement()!
        let edges = givenRandomWeightedEdges()
        let graph = AdjacencyList(kind: kind, edges: edges)
        
        sut = GraphDegrees(graph: graph)
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.graph, graph)
    }
    
    // MARK: - allEdges tests
    func testAllEdges_whenGraphHasNoEdges() {
        whenGraphHasNoEdges(kind: .directed)
        XCTAssertEqual(sut.allEdges, [])
        
        whenGraphHasNoEdges(kind: .undirected)
        XCTAssertEqual(sut.allEdges, [])
    }
    
    func testAllEdges_whenGraphHasEdges() {
        whenGraphHasEdges(kind: .directed)
        var expectedResult = sut.graph._adjacencies.flatMap({ $0 })
        
        XCTAssertEqual(sut.allEdges, expectedResult)
        
        whenGraphHasEdges(kind: .undirected)
        expectedResult = []
        // In undirected graphs self loops are listed two times as edges in adjacencies
        // and we must count them only once, as well as we must esclude edges already
        // counted from the destination back to the origin:
        for vertex in 0..<sut.graph.vertexCount {
            guard !sut.graph.adjacencies(vertex: vertex).isEmpty else { continue }
            
            var addSelfLoop = true
            let edges = sut.graph.adjacencies(vertex: vertex).filter({ edge in
                guard !edge.isSelfLoop else {
                    defer { addSelfLoop = !addSelfLoop }
                    
                    return addSelfLoop
                }
                
                return edge.other(vertex) > vertex
            })
            expectedResult.append(contentsOf: edges)
        }
        
        XCTAssertEqual(sut.allEdges, expectedResult)
    }
    
    // MARK: - maxOutdegree tests
    func testMaxOutdegree_whenGraphHasNoEdges() {
        whenGraphHasNoEdges(kind: .directed)
        XCTAssertEqual(sut.maxOutdegree, 0)
        
        whenGraphHasNoEdges(kind: .undirected)
        XCTAssertEqual(sut.maxOutdegree, 0)
    }
    
    func testMaxOutdegree_whenGraphHasEdges() {
        whenGraphHasEdges(kind: .directed)
        var expectedResult = 0
        for vertex in 0..<sut.graph.vertexCount {
            expectedResult = Swift.max(expectedResult, sut.graph.adjacencies(vertex: vertex).count)
        }
        
        XCTAssertEqual(sut.maxOutdegree, expectedResult)
        
        whenGraphHasEdges(kind: .undirected)
        expectedResult = 0
        for vertex in 0..<sut.graph.vertexCount {
            expectedResult = Swift.max(expectedResult, sut.graph.adjacencies(vertex: vertex).count)
        }
        
        XCTAssertEqual(sut.maxOutdegree, expectedResult)
    }
    
    // MARK: - averageOutdegree tests
    func testAverageOutdegree_whenGraphHasNoVertices() {
        whenGraphHasNoVertices()
        XCTAssertEqual(sut.averageOutdegree, 0)
    }
    
    func testAverageOutdegree_whenGraphHasNoEdges() {
        whenGraphHasNoEdges(kind: .directed)
        XCTAssertEqual(sut.averageOutdegree, 0)
        
        whenGraphHasNoEdges(kind: .undirected)
        XCTAssertEqual(sut.averageOutdegree, 0)
    }
    
    func testAverageOutdegree_whenGraphHasEdges() {
        whenGraphHasEdges(kind: .directed)
        var expectedResult: Double = Double(sut.graph._adjacencies.reduce(0, {$0 + $1.count })) / Double(sut.graph.vertexCount)
        XCTAssertEqual(sut.averageOutdegree, expectedResult)
        
        whenGraphHasEdges(kind: .undirected)
        expectedResult = Double(sut.graph._adjacencies.reduce(0, {$0 + $1.count })) / Double(sut.graph.vertexCount)
        XCTAssertEqual(sut.averageOutdegree, expectedResult)
    }
    
    // MARK: - countOfSelfLoops tests
    func testCountOfSelfLoops_whenGraphHasNoEdges() {
        whenGraphHasNoEdges(kind: .directed)
        XCTAssertEqual(sut.countOfSelfLoops, 0)
        
        whenGraphHasNoEdges(kind: .undirected)
        XCTAssertEqual(sut.countOfSelfLoops, 0)
    }
    
    func testCountOfSelfLoops_whenGraphHasEdges() {
        whenGraphHasEdges(kind: .directed)
        var expectedResult = sut.allEdges.filter({ $0.isSelfLoop }).count
        XCTAssertEqual(sut.countOfSelfLoops, expectedResult)
        
        whenGraphHasEdges(kind: .undirected)
        expectedResult = sut.allEdges.filter({ $0.isSelfLoop }).count
        XCTAssertEqual(sut.countOfSelfLoops, expectedResult)
    }
    
    // MARK: - outdegree(of:) tests
    func testOudegreeOf_whenGraphHasNoEdges() {
        whenGraphHasNoEdges(kind: .directed)
        for vertex in 0..<sut.graph.vertexCount {
            XCTAssertEqual(sut.outdegree(of: vertex), 0)
        }
        
        whenGraphHasNoEdges(kind: .undirected)
        for vertex in 0..<sut.graph.vertexCount {
            XCTAssertEqual(sut.outdegree(of: vertex), 0)
        }
    }
    
    func testOutdegreeOf_whenGraphHasVertices() {
        whenGraphHasEdges(kind: .directed)
        for vertex in 0..<sut.graph.vertexCount {
            XCTAssertEqual(sut.outdegree(of: vertex), sut.graph.adjacencies(vertex: vertex).count)
        }
        
        whenGraphHasEdges(kind: .undirected)
        for vertex in 0..<sut.graph.vertexCount {
            XCTAssertEqual(sut.outdegree(of: vertex), sut.graph.adjacencies(vertex: vertex).count)
        }
    }
    
    // MARK: - indegree(of:) tests
    func testIndegreeOf_whenGraphHasNoEdges() {
        whenGraphHasNoEdges(kind: .directed)
        for vertex in 0..<sut.graph.vertexCount {
            XCTAssertEqual(sut.indegree(of: vertex), 0)
        }
        
        whenGraphHasNoEdges(kind: .undirected)
        for vertex in 0..<sut.graph.vertexCount {
            XCTAssertEqual(sut.indegree(of: vertex), 0)
        }
    }
    
    func testIndegreeOf_whenGraphHasEdges() {
        whenGraphHasEdges(kind: .directed)
        var indegrees = Array<Int>(repeating: 0, count: sut.graph.vertexCount)
        sut.graph
            .depthFirstSearch(
                preOrderVertexVisit: {_ in },
                visitingVertexAdjacency: { vertex, edge, _ in
                    let other = edge.other(vertex)
                    indegrees[other] += 1
                },
                postOrderVertexVisit: { _ in }
            )
        for vertex in 0..<sut.graph.vertexCount {
            XCTAssertEqual(sut.indegree(of: vertex), indegrees[vertex])
        }
        
        whenGraphHasEdges(kind: .undirected)
        indegrees = Array<Int>(repeating: 0, count: sut.graph.vertexCount)
        sut.graph
            .depthFirstSearch(
                preOrderVertexVisit: {_ in },
                visitingVertexAdjacency: { vertex, edge, _ in
                    let other = edge.other(vertex)
                    indegrees[other] += 1
                },
                postOrderVertexVisit: { _ in }
            )
        for vertex in 0..<sut.graph.vertexCount {
            XCTAssertEqual(sut.indegree(of: vertex), indegrees[vertex])
        }
    }
    
    func testIndegreeOf_memoizedResults() {
        whenGraphHasEdges(kind: .directed)
        var indegrees = Array<Int?>(repeating: nil, count: sut.graph.vertexCount)
        for vertex in 0..<sut.graph.vertexCount {
            indegrees[vertex] = sut.indegree(of: vertex)
            XCTAssertEqual(indegrees[vertex], sut.indegree(of: vertex))
        }
        
        whenGraphHasEdges(kind: .undirected)
        indegrees = Array<Int?>(repeating: nil, count: sut.graph.vertexCount)
        for vertex in 0..<sut.graph.vertexCount {
            indegrees[vertex] = sut.indegree(of: vertex)
            XCTAssertEqual(indegrees[vertex], sut.indegree(of: vertex))
        }
    }
    
}
