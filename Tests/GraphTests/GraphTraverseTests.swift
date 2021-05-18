//
//  GraphTraverseTests.swift
//  GraphTests
//
//  Created by Valeriano Della Longa on 2021/05/10.
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

// MARK: - GraphTraversal enum tests
final class GraphTraversalTests: XCTestCase {
    func testDeepFirstSearch() {
        let sut = GraphTraversal.DeepFirstSearch
        XCTAssertEqual(sut, GraphTraversal.DeepFirstSearch)
    }
    
    func testBreadthFirstSearch() {
        let sut = GraphTraversal.BreadthFirstSearch
        XCTAssertEqual(sut, GraphTraversal.BreadthFirstSearch)
    }
    
    func testAllCases() {
        let expectedResult: Set<GraphTraversal> = [.DeepFirstSearch, .BreadthFirstSearch]
        let allCases = Set(GraphTraversal.allCases)
        XCTAssertEqual(allCases, expectedResult)
    }
    
    func testEncodeDecode() {
        var sut: GraphTraversal = .DeepFirstSearch
        var data: Data? = nil
        XCTAssertNoThrow(try data = JSONEncoder().encode(sut))
        if let encoded = data {
            var decoded: GraphTraversal? = nil
            XCTAssertNoThrow(try decoded = JSONDecoder().decode(GraphTraversal.self, from: encoded))
            XCTAssertEqual(decoded, sut)
        }
        
        sut = .BreadthFirstSearch
        data = nil
        XCTAssertNoThrow(try data = JSONEncoder().encode(sut))
        if let encoded = data {
            var decoded: GraphTraversal? = nil
            XCTAssertNoThrow(try decoded = JSONDecoder().decode(GraphTraversal.self, from: encoded))
            XCTAssertEqual(decoded, sut)
        }
    }
    
}

// MARK: - Graph+Traverse tests
final class GraphTraverseTests: GraphBaseTests {
    // MARK: - Given
    func givenEdgesForTraversalTests() -> [WeightedEdge<Double>] {
        var edges: [WeightedEdge<Double>] = []
        edges.append(WeightedEdge(tail: 0, head: 3, weight: 1.5))
        edges.append(WeightedEdge(tail: 3, head: 4, weight: 3.5))
        edges.append(WeightedEdge(tail: 4, head: 5, weight: 5.5))
        edges.append(WeightedEdge(tail: 5, head: 7, weight: 6.5))
        edges.append(WeightedEdge(tail: 7, head: 8, weight: 7.5))
        edges.append(WeightedEdge(tail: 8, head: 9, weight: 8.5))
        edges.append(WeightedEdge(tail: 3, head: 6, weight: 4.5))
        edges.append(WeightedEdge(tail: 0, head: 1, weight: 0.5))
        edges.append(WeightedEdge(tail: 1, head: 2, weight: 2.5))
        
        //          (0)
        //         /   \
        //      (1)     (3)
        //       |     /   \
        //      (2)  (6)   (4)
        //                  |
        //                 (5)
        //                  |
        //                 (7)
        //                  |
        //                 (8)
        //                  |
        //                 (9)
        
        return edges
    }
    
    // MARK: - When
    func whenIsDirectedWithEdgesNotParallelNorSelfCycleNorTwoWaysAdjacencies() {
        let edges = givenEdgesNotParallelNorSelfCycleNorTwoWaysAdjacencies()
        sut = AdjacencyList(kind: .directed, edges: edges)
    }
    
    func whenIsUndirectedWithEdgesNotParallelNorSelfCycle() {
        let edges = givenEdgesNotParallelNorSelfCycleNorTwoWaysAdjacencies()
        sut = AdjacencyList(kind: .undirected, edges: edges)
    }
    
    func whenIsConnectedDirectedGraph() {
        let edges = givenEdgesConnectedOneToEachOtherAscending()
        sut = AdjacencyList(kind: .directed, edges: edges)
    }
    
    func whenIsConnectedUndirectedGraph() {
        let edges = givenEdgesConnectedOneToEachOtherAscending()
        sut = AdjacencyList(kind: .undirected, edges: edges)
    }
    
    // MARK: - Tests
    // MARK: - visitEveryVertexAdjacency(adopting:body:)
    func testVisitEveryVertexAdjacency_whenNoVerticesInGraph_thenBodyNeverExecutes() {
        var countOfExecutions = 0
        let body: (Int, WeightedEdge<Double>) -> Void = { _, _ in
            countOfExecutions += 1
        }
        sut = AdjacencyList(kind: .directed, vertexCount: 0)
        sut.visitEveryVertexAdjacency(adopting: .DeepFirstSearch, body)
        XCTAssertEqual(countOfExecutions, 0)
        
        countOfExecutions = 0
        sut.visitEveryVertexAdjacency(adopting: .BreadthFirstSearch, body)
        XCTAssertEqual(countOfExecutions, 0)
        
        countOfExecutions = 0
        sut = AdjacencyList(kind: .undirected, vertexCount: 0)
        sut.visitEveryVertexAdjacency(adopting: .DeepFirstSearch, body)
        XCTAssertEqual(countOfExecutions, 0)
        
        countOfExecutions = 0
        sut.visitEveryVertexAdjacency(adopting: .DeepFirstSearch, body)
        XCTAssertEqual(countOfExecutions, 0)
    }
    
    func testVisitEveryVertexAdjacency_whenNoEdgesInGraph_thenBodyNeverExecutes() {
        var countOfExecutions = 0
        let body: (Int, WeightedEdge<Double>) -> Void = { _, _ in
            countOfExecutions += 1
        }
        
        sut = AdjacencyList(kind: .directed, vertexCount: Int.random(in: 1..<100))
        sut.visitEveryVertexAdjacency(adopting: .DeepFirstSearch, body)
        XCTAssertEqual(countOfExecutions, 0)
        
        countOfExecutions = 0
        sut.visitEveryVertexAdjacency(adopting: .BreadthFirstSearch, body)
        XCTAssertEqual(countOfExecutions, 0)
        
        countOfExecutions = 0
        sut = AdjacencyList(kind: .undirected, vertexCount: Int.random(in: 1..<100))
        sut.visitEveryVertexAdjacency(adopting: .DeepFirstSearch, body)
        XCTAssertEqual(countOfExecutions, 0)
        
        countOfExecutions = 0
        sut.visitEveryVertexAdjacency(adopting: .DeepFirstSearch, body)
        XCTAssertEqual(countOfExecutions, 0)
    }
    
    func testVisitEveryVertexAdjacency_whenEdgesInGraphAreNotSelfCycleNorParallel_thenBodyExecutesForEveryAdjacencyOnce() {
        var countOfExecutions = 0
        let body: (Int, WeightedEdge<Double>) -> Void = { _, _ in
            countOfExecutions += 1
        }
        // In .directed graph two way adjacency are just visited once, hence we
        // test it without directed edges going in both direction on same vertices:
        whenIsDirectedWithEdgesNotParallelNorSelfCycleNorTwoWaysAdjacencies()
        sut.visitEveryVertexAdjacency(adopting: .DeepFirstSearch, body)
        XCTAssertEqual(countOfExecutions, sut.edgeCount)
        
        countOfExecutions = 0
        sut.visitEveryVertexAdjacency(adopting: .BreadthFirstSearch, body)
        XCTAssertEqual(countOfExecutions, sut.edgeCount)
        
        // In .undirected graph adjacendies are visited just once too:
        whenIsUndirectedWithEdgesNotParallelNorSelfCycle()
        countOfExecutions = 0
        sut.visitEveryVertexAdjacency(adopting: .DeepFirstSearch, body)
        XCTAssertEqual(countOfExecutions, sut.edgeCount)
        
        countOfExecutions = 0
        sut.visitEveryVertexAdjacency(adopting: .BreadthFirstSearch, body)
        XCTAssertEqual(countOfExecutions, sut.edgeCount)
    }
    
    func testVisitEveryVertexAdjacency_whenBodyThrows_thenRethrows() {
        let body: (Int, WeightedEdge<Double>) throws -> Void = { _, _ in
            throw err
        }
        
        whenIsDirectedWithEdgesNotParallelNorSelfCycleNorTwoWaysAdjacencies()
        do {
            try sut.visitEveryVertexAdjacency(adopting: .DeepFirstSearch, body)
            XCTFail("didn't rethrow")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
        
        do {
            try sut.visitEveryVertexAdjacency(adopting: .BreadthFirstSearch, body)
            XCTFail("didn't rethrow")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
        
        whenIsUndirectedWithEdgesNotParallelNorSelfCycle()
        do {
            try sut.visitEveryVertexAdjacency(adopting: .DeepFirstSearch, body)
            XCTFail("didn't rethrow")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
        
        do {
            try sut.visitEveryVertexAdjacency(adopting: .BreadthFirstSearch, body)
            XCTFail("didn't rethrow")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
    }
    
    // MARK: - visitedVertices(adopting:reachableFrom:body:) tests
    func testVisitedVerticesReachableFrom_whenNoEdgesInGraph_thenBodyNeverExecutesAndReturnsSetContainingSourceOnly() {
        var countOfExecutions = 0
        let body: (Int, WeightedEdge<Double>) -> Void = { _, _ in
            countOfExecutions += 1
        }
        let vertexCount = Int.random(in: 1..<100)
        sut = AdjacencyList(kind: .directed, vertexCount: vertexCount)
        for vertex in 0..<vertexCount {
            countOfExecutions = 0
            XCTAssertEqual(sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: vertex, body), [vertex])
            XCTAssertEqual(countOfExecutions, 0)
            
            countOfExecutions = 0
            XCTAssertEqual(sut.visitedVertices(adopting: .BreadthFirstSearch, reachableFrom: vertex, body), [vertex])
            XCTAssertEqual(countOfExecutions, 0)
        }
        
        sut = AdjacencyList(kind: .undirected, vertexCount: vertexCount)
        for vertex in 0..<vertexCount {
            countOfExecutions = 0
            XCTAssertEqual(sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: vertex, body), [vertex])
            XCTAssertEqual(countOfExecutions, 0)
            
            countOfExecutions = 0
            XCTAssertEqual(sut.visitedVertices(adopting: .BreadthFirstSearch, reachableFrom: vertex, body), [vertex])
            XCTAssertEqual(countOfExecutions, 0)
        }
    }
    
    func testVisitedVerticesReachableFrom_whenEdgesInGraphAndSourceHasNoAdjacencies_thenBodyNeverExecutesAndReturnsSetContainingSourceOnly() {
        var countOfExecutions = 0
        let body: (Int, WeightedEdge<Double>) -> Void = { _, _ in
            countOfExecutions += 1
        }
        whenIsDirectedWithEdgesNotParallelNorSelfCycleNorTwoWaysAdjacencies()
        for vertex in 0..<sut.vertexCount where sut._adjacencies[vertex].isEmpty {
            countOfExecutions = 0
            XCTAssertEqual(sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: vertex, body), [vertex])
            XCTAssertEqual(countOfExecutions, 0)
            
            countOfExecutions = 0
            XCTAssertEqual(sut.visitedVertices(adopting: .BreadthFirstSearch, reachableFrom: vertex, body), [vertex])
            XCTAssertEqual(countOfExecutions, 0)
        }
        
        whenIsUndirectedWithEdgesNotParallelNorSelfCycle()
        for vertex in 0..<sut.vertexCount where sut._adjacencies[vertex].isEmpty {
            countOfExecutions = 0
            XCTAssertEqual(sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: vertex, body), [vertex])
            XCTAssertEqual(countOfExecutions, 0)
            
            countOfExecutions = 0
            XCTAssertEqual(sut.visitedVertices(adopting: .BreadthFirstSearch, reachableFrom: vertex, body), [vertex])
            XCTAssertEqual(countOfExecutions, 0)
        }
    }
    
    func testVisitedVerticesReachableFrom_whenGraphContainsEdgesAndSourceHasAdjacencies_thenBodyExecutesAndReturnsVisitedVerticesIncludingSource() {
        var countOfExecutions = 0
        let body: (Int, WeightedEdge<Double>) -> Void = { _, _ in
            countOfExecutions += 1
        }
        whenIsConnectedDirectedGraph()
        for vertex in 0..<sut.vertexCount {
            countOfExecutions = 0
            XCTAssertEqual(sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: vertex, body), Set(vertex..<sut.vertexCount))
            XCTAssertEqual(countOfExecutions, sut.edgeCount - vertex)
            
            countOfExecutions = 0
            XCTAssertEqual(sut.visitedVertices(adopting: .BreadthFirstSearch, reachableFrom: vertex, body), Set(vertex..<sut.vertexCount))
            XCTAssertEqual(countOfExecutions, sut.edgeCount - vertex)
        }
        
        whenIsConnectedUndirectedGraph()
        for vertex in 0..<sut.vertexCount {
            countOfExecutions = 0
            XCTAssertEqual(sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: vertex, body), Set(0..<sut.vertexCount))
            XCTAssertEqual(countOfExecutions, sut.vertexCount - 1)
            
            countOfExecutions = 0
            XCTAssertEqual(sut.visitedVertices(adopting: .BreadthFirstSearch, reachableFrom: vertex, body), Set(0..<sut.vertexCount))
            XCTAssertEqual(countOfExecutions, sut.vertexCount - 1)
        }
    }
    
    func testVisitedVerticesReachableFrom_whenBodyThrows_thenRethrows() {
        let body: (Int, WeightedEdge<Double>) throws -> Void = { _, _ in
            throw err
        }
        whenIsConnectedUndirectedGraph()
        do {
            try sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: 0, body)
            XCTFail("has not rethrown.")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
        
        do {
            try sut.visitedVertices(adopting: .BreadthFirstSearch, reachableFrom: 0, body)
            XCTFail("has not rethrown.")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
        
        whenIsConnectedUndirectedGraph()
        do {
            try sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: 0, body)
            XCTFail("has not rethrown.")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
        
        do {
            try sut.visitedVertices(adopting: .BreadthFirstSearch, reachableFrom: 0, body)
            XCTFail("has not rethrown.")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
    }
    
    // MARK: - visitAllVertices(adopting:body:) tests
    func testVisitAllVertices_whenNoVertexInGraph_thenBodyNeverExecutes() {
        var countOfExecutions = 0
        let body: (Int) -> Void = { _ in
            countOfExecutions += 1
        }
        sut = AdjacencyList(kind: .directed, vertexCount: 0)
        sut.visitAllVertices(adopting: .DeepFirstSearch, body)
        XCTAssertEqual(countOfExecutions, 0)
        
        countOfExecutions = 0
        sut.visitAllVertices(adopting: .BreadthFirstSearch, body)
        XCTAssertEqual(countOfExecutions, 0)
        
        countOfExecutions = 0
        sut = AdjacencyList(kind: .undirected, vertexCount: 0)
        sut.visitAllVertices(adopting: .DeepFirstSearch, body)
        XCTAssertEqual(countOfExecutions, 0)
        
        countOfExecutions = 0
        sut.visitAllVertices(adopting: .BreadthFirstSearch, body)
        XCTAssertEqual(countOfExecutions, 0)
    }
    
    func testVisitAllVertices_whenNoEdgesInGraph_thenBodyExecutesOnEveryVertex() {
        var visitedVertices: Set<Int> = []
        let body: (Int) -> Void = { visitedVertices.insert($0) }
        let vertexCount = Int.random(in: 10..<100)
        sut = AdjacencyList(kind: .directed, vertexCount: vertexCount)
        sut.visitAllVertices(adopting: .DeepFirstSearch, body)
        XCTAssertEqual(visitedVertices.count, vertexCount)
        
        visitedVertices.removeAll()
        sut.visitAllVertices(adopting: .BreadthFirstSearch, body)
        XCTAssertEqual(visitedVertices.count, vertexCount)
        
        visitedVertices.removeAll()
        sut = AdjacencyList(kind: .undirected, vertexCount: vertexCount)
        sut.visitAllVertices(adopting: .DeepFirstSearch, body)
        XCTAssertEqual(visitedVertices.count, vertexCount)
        
        visitedVertices.removeAll()
        sut.visitAllVertices(adopting: .BreadthFirstSearch, body)
        XCTAssertEqual(visitedVertices.count, vertexCount)
    }
    
    func testVisitAllVertices_whenEdgesInGraph_thenBodyExecutesOnEveryVertex() {
        var visitedVertices: Set<Int> = []
        let body: (Int) -> Void = { visitedVertices.insert($0) }
        
        whenIsConnectedDirectedGraph()
        sut.visitAllVertices(adopting: .DeepFirstSearch, body)
        XCTAssertEqual(visitedVertices.count, sut.vertexCount)
        
        visitedVertices.removeAll()
        sut.visitAllVertices(adopting: .BreadthFirstSearch, body)
        XCTAssertEqual(visitedVertices.count, sut.vertexCount)
        
        visitedVertices.removeAll()
        whenIsConnectedUndirectedGraph()
        sut.visitAllVertices(adopting: .DeepFirstSearch, body)
        XCTAssertEqual(visitedVertices.count, sut.vertexCount)
        
        visitedVertices.removeAll()
        sut.visitAllVertices(adopting: .BreadthFirstSearch, body)
        XCTAssertEqual(visitedVertices.count, sut.vertexCount)
    }
    
    func testVisitAllVertecies_whenBodyThrows_thenRethrows() {
        let body: (Int) throws -> Void = { _ in throw err }
        whenIsConnectedUndirectedGraph()
        do {
            try sut.visitAllVertices(adopting: .DeepFirstSearch, body)
            XCTFail("has not rethrown.")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
        
        do {
            try sut.visitAllVertices(adopting: .DeepFirstSearch, body)
            XCTFail("has not rethrown.")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
        
        whenIsConnectedUndirectedGraph()
        do {
            try sut.visitAllVertices(adopting: .DeepFirstSearch, body)
            XCTFail("has not rethrown.")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
        
        do {
            try sut.visitAllVertices(adopting: .DeepFirstSearch, body)
            XCTFail("has not rethrown.")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
    }
    
    // MARK: - visitedVertices(adopting:reachableFrom:body) tests
    func testVisitedVerticesReachableFrom_2_whenSourceIsDisconnected_thenBodyExecutesOnlyOnceAndReturnsSetContainingOnlySource() {
        var countOfExecutions = 0
        let body: (Int) -> Void = { _ in countOfExecutions += 1 }
        let vertexCount = Int.random(in: 10..<100)
        sut = AdjacencyList(kind: .directed, vertexCount: vertexCount)
        for vertex in 0..<vertexCount {
            countOfExecutions = 0
            XCTAssertEqual(sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: vertex, body), [vertex])
            XCTAssertEqual(countOfExecutions, 1)
            
            countOfExecutions = 0
            XCTAssertEqual(sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: vertex, body), [vertex])
            XCTAssertEqual(countOfExecutions, 1)
        }
        
        sut = AdjacencyList(kind: .undirected, vertexCount: vertexCount)
        for vertex in 0..<vertexCount {
            countOfExecutions = 0
            XCTAssertEqual(sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: vertex, body), [vertex])
            XCTAssertEqual(countOfExecutions, 1)
            
            countOfExecutions = 0
            XCTAssertEqual(sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: vertex, body), [vertex])
            XCTAssertEqual(countOfExecutions, 1)
        }
    }
    
    func testVisitedVerticesReachableFrom_2_whenSourceIsConnected_thenBodyExecutesForAllVerticesReachableFromVertexAndReturnsSetContainingVisitedVertices() {
        var inOrderVisited = [Int]()
        let body: (Int) -> Void = { inOrderVisited.append($0) }
        whenIsConnectedDirectedGraph()
        for vertex in 0..<sut.vertexCount where !sut._adjacencies[vertex].isEmpty {
            inOrderVisited.removeAll()
            XCTAssertEqual(sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: vertex, body), Set(inOrderVisited))
            
            inOrderVisited.removeAll()
            XCTAssertEqual(sut.visitedVertices(adopting: .BreadthFirstSearch, reachableFrom: vertex, body), Set(inOrderVisited))
        }
        
        whenIsConnectedUndirectedGraph()
        for vertex in 0..<sut.vertexCount where !sut._adjacencies[vertex].isEmpty {
            inOrderVisited.removeAll()
            XCTAssertEqual(sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: vertex, body), Set(inOrderVisited))
            
            inOrderVisited.removeAll()
            XCTAssertEqual(sut.visitedVertices(adopting: .BreadthFirstSearch, reachableFrom: vertex, body), Set(inOrderVisited))
        }
    }
    
    func testVisitedVerticesReachableFrom_2_whenBodyThrows_thenRethrows() {
        let body: (Int) throws -> Void = { _ in throw err }
        whenIsConnectedUndirectedGraph()
        do {
            try sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: 0, body)
            XCTFail("has not rethrown.")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
        
        do {
            try sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: 0, body)
            XCTFail("has not rethrown.")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
        
        whenIsConnectedUndirectedGraph()
        do {
            try sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: 0, body)
            XCTFail("has not rethrown.")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
        
        do {
            try sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: 0, body)
            XCTFail("has not rethrown.")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
    }
    
    // MARK: - depthFirstSearch(preOrderVertexVisit:visitingVertexAdjacency:postOrderVertexVisit:) tests
    func testDepthFirstSearch_whenGraphHasNoVerticesThenNoGivenClosureExecutes() {
        var preOrderCount = 0
        let preOrder: (Int) -> Void = { _ in preOrderCount += 1 }
        var adjCount = 0
        let adj: (Int, WeightedEdge<Double>, Bool) -> Void = { _, _, _ in adjCount += 1 }
        var postOrderCount = 0
        let postOrder: (Int) -> Void = { _ in postOrderCount += 1 }
        sut = AdjacencyList(kind: .directed, vertexCount: 0)
        sut.depthFirstSearch(preOrderVertexVisit: preOrder, visitingVertexAdjacency: adj, postOrderVertexVisit: postOrder)
        XCTAssertEqual(preOrderCount, 0)
        XCTAssertEqual(adjCount, 0)
        XCTAssertEqual(postOrderCount, 0)
        
        preOrderCount = 0
        adjCount = 0
        postOrderCount = 0
        sut = AdjacencyList(kind: .undirected, vertexCount: 0)
        sut.depthFirstSearch(preOrderVertexVisit: preOrder, visitingVertexAdjacency: adj, postOrderVertexVisit: postOrder)
        XCTAssertEqual(preOrderCount, 0)
        XCTAssertEqual(adjCount, 0)
        XCTAssertEqual(postOrderCount, 0)
    }
    
    func testDepthFirstSearch_whenGraphHasVerticesButNoEdges_preorderVertexAndPostOrderVertexExecutesOnEachVertexVisitingVertexAdjacencyNeverExecutes() {
        var preorderVisited: Array<Int> = []
        let preOrder: (Int) -> Void = { preorderVisited.append($0) }
        var adjCount = 0
        let adj: (Int, WeightedEdge<Double>, Bool) -> Void = { _, _, _ in adjCount += 1 }
        var postOrderVisted: Array<Int> = []
        let postOrder: (Int) -> Void = { postOrderVisted.append($0) }
        
        let vertexCount = Int.random(in: 10..<100)
        sut = AdjacencyList(kind: .directed, vertexCount: vertexCount)
        sut.depthFirstSearch(preOrderVertexVisit: preOrder, visitingVertexAdjacency: adj, postOrderVertexVisit: postOrder)
        XCTAssertEqual(Set(preorderVisited), Set(0..<vertexCount))
        XCTAssertEqual(adjCount, 0)
        XCTAssertEqual(Set(postOrderVisted), Set(0..<vertexCount))
        
        preorderVisited.removeAll()
        adjCount = 0
        postOrderVisted.removeAll()
        sut = AdjacencyList(kind: .undirected, vertexCount: vertexCount)
        sut.depthFirstSearch(preOrderVertexVisit: preOrder, visitingVertexAdjacency: adj, postOrderVertexVisit: postOrder)
        XCTAssertEqual(Set(preorderVisited), Set(0..<vertexCount))
        XCTAssertEqual(adjCount, 0)
        XCTAssertEqual(Set(postOrderVisted), Set(0..<vertexCount))
    }
    
    func testDepthFirstSearch_whenGraphHasEdges_thenVisitingVertexAdjacencyExecutesForEachEdge() {
        var preorderVisited: Set<Int> = []
        let preorder: (Int) -> Void = { preorderVisited.insert($0) }
        var postorderVisited: Set<Int> = []
        let postorder: (Int) -> Void = { postorderVisited.insert($0) }
        var countOfAdjExecutions = 0
        let adj: (Int, WeightedEdge<Double>, Bool) -> Void = { visitingVertex, edge, hasBeenVisited in
            XCTAssertTrue(preorderVisited.contains(visitingVertex))
            let other = edge.other(visitingVertex)
            XCTAssertEqual(preorderVisited.contains(other), hasBeenVisited)
            XCTAssertFalse(postorderVisited.contains(visitingVertex))
            countOfAdjExecutions += 1
        }
        
        whenIsConnectedDirectedGraph()
        sut.depthFirstSearch(preOrderVertexVisit: preorder, visitingVertexAdjacency: adj, postOrderVertexVisit: postorder)
        XCTAssertEqual(countOfAdjExecutions, sut.edgeCount)
        
        preorderVisited.removeAll()
        postorderVisited.removeAll()
        countOfAdjExecutions = 0
        
        whenIsConnectedUndirectedGraph()
        sut.depthFirstSearch(preOrderVertexVisit: preorder, visitingVertexAdjacency: adj, postOrderVertexVisit: postorder)
        XCTAssertEqual(countOfAdjExecutions, sut.edgeCount * 2)
    }
    
    func testDepthFirstSearch_whenPreorderVisitVertexThrows_thenRethrows() {
        let preorder: (Int) throws -> Void = { _ in throw err }
        whenIsConnectedDirectedGraph()
        do {
            try sut.depthFirstSearch(preOrderVertexVisit: preorder, visitingVertexAdjacency: { _, _, _ in }, postOrderVertexVisit: { _ in })
            XCTFail("Has not rethrown")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
        
        whenIsConnectedUndirectedGraph()
        do {
            try sut.depthFirstSearch(preOrderVertexVisit: preorder, visitingVertexAdjacency: { _, _, _ in }, postOrderVertexVisit: { _ in })
            XCTFail("Has not rethrown")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
    }
    
    func testDepthFirstSearch_whenVisitingVertexAdjacencyThrows_thenRethrows() {
        let adj: (Int, WeightedEdge<Double>, Bool) throws -> Void = { _, _, _ in
            throw err
        }
        whenIsConnectedDirectedGraph()
        do {
            try sut.depthFirstSearch(preOrderVertexVisit: {_ in }, visitingVertexAdjacency: adj, postOrderVertexVisit: { _ in })
            XCTFail("Has not rethrown.")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
        
        whenIsConnectedUndirectedGraph()
        do {
            try sut.depthFirstSearch(preOrderVertexVisit: {_ in }, visitingVertexAdjacency: adj, postOrderVertexVisit: { _ in })
            XCTFail("Has not rethrown.")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
    }
    
    func testDepthFirstSearch_whenPostOrderVertexVisitThrows_thenRethrows() {
        let postorder: (Int) throws -> Void = { _ in throw err }
        whenIsConnectedDirectedGraph()
        do {
            try sut.depthFirstSearch(preOrderVertexVisit: { _ in }, visitingVertexAdjacency: { _, _, _ in }, postOrderVertexVisit: postorder)
            XCTFail("Has not rethrown")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
        
        whenIsConnectedUndirectedGraph()
        do {
            try sut.depthFirstSearch(preOrderVertexVisit: { _ in }, visitingVertexAdjacency: { _, _, _ in }, postOrderVertexVisit: postorder)
            XCTFail("Has not rethrown")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
    }
    
    // MARK: - breadthFirstSearch(preOrderVertexVisit:visitingVertexAdjacency:postOrderVertexVisit:) tests
    func testBreadthFirstSearch_whenGraphHasNoVerticesThenNoGivenClosureExecutes() {
        var preOrderCount = 0
        let preOrder: (Int) -> Void = { _ in preOrderCount += 1 }
        var adjCount = 0
        let adj: (Int, WeightedEdge<Double>, Bool) -> Void = { _, _, _ in adjCount += 1 }
        var postOrderCount = 0
        let postOrder: (Int) -> Void = { _ in postOrderCount += 1 }
        sut = AdjacencyList(kind: .directed, vertexCount: 0)
        sut.breadthFirstSearch(preOrderVertexVisit: preOrder, visitingVertexAdjacency: adj, postOrderVertexVisit: postOrder)
        XCTAssertEqual(preOrderCount, 0)
        XCTAssertEqual(adjCount, 0)
        XCTAssertEqual(postOrderCount, 0)
        
        preOrderCount = 0
        adjCount = 0
        postOrderCount = 0
        sut = AdjacencyList(kind: .undirected, vertexCount: 0)
        sut.breadthFirstSearch(preOrderVertexVisit: preOrder, visitingVertexAdjacency: adj, postOrderVertexVisit: postOrder)
        XCTAssertEqual(preOrderCount, 0)
        XCTAssertEqual(adjCount, 0)
        XCTAssertEqual(postOrderCount, 0)
    }
    
    func testBreadthFirstSearch_whenGraphHasVerticesButNoEdges_preorderVertexAndPostOrderVertexExecutesOnEachVertexVisitingVertexAdjacencyNeverExecutes() {
        var preorderVisited: Array<Int> = []
        let preOrder: (Int) -> Void = { preorderVisited.append($0) }
        var adjCount = 0
        let adj: (Int, WeightedEdge<Double>, Bool) -> Void = { _, _, _ in adjCount += 1 }
        var postOrderVisted: Array<Int> = []
        let postOrder: (Int) -> Void = { postOrderVisted.append($0) }
        
        let vertexCount = Int.random(in: 10..<100)
        sut = AdjacencyList(kind: .directed, vertexCount: vertexCount)
        sut.breadthFirstSearch(preOrderVertexVisit: preOrder, visitingVertexAdjacency: adj, postOrderVertexVisit: postOrder)
        XCTAssertEqual(Set(preorderVisited), Set(0..<vertexCount))
        XCTAssertEqual(adjCount, 0)
        XCTAssertEqual(Set(postOrderVisted), Set(0..<vertexCount))
        
        preorderVisited.removeAll()
        adjCount = 0
        postOrderVisted.removeAll()
        sut = AdjacencyList(kind: .undirected, vertexCount: vertexCount)
        sut.breadthFirstSearch(preOrderVertexVisit: preOrder, visitingVertexAdjacency: adj, postOrderVertexVisit: postOrder)
        XCTAssertEqual(Set(preorderVisited), Set(0..<vertexCount))
        XCTAssertEqual(adjCount, 0)
        XCTAssertEqual(Set(postOrderVisted), Set(0..<vertexCount))
    }
    
    func testBreadthFirstSearch_whenGraphHasEdges_thenVisitingVertexAdjacencyExecutesForEachEdge() {
        var preorderVisited: Set<Int> = []
        let preorder: (Int) -> Void = { preorderVisited.insert($0) }
        var postorderVisited: Set<Int> = []
        let postorder: (Int) -> Void = { postorderVisited.insert($0) }
        var countOfAdjExecutions = 0
        let adj: (Int, WeightedEdge<Double>, Bool) -> Void = { visitingVertex, edge, hasBeenVisited in
            XCTAssertTrue(preorderVisited.contains(visitingVertex))
            let other = edge.other(visitingVertex)
            XCTAssertEqual(preorderVisited.contains(other), hasBeenVisited)
            XCTAssertFalse(postorderVisited.contains(visitingVertex))
            countOfAdjExecutions += 1
        }
        
        whenIsConnectedDirectedGraph()
        sut.breadthFirstSearch(preOrderVertexVisit: preorder, visitingVertexAdjacency: adj, postOrderVertexVisit: postorder)
        XCTAssertEqual(countOfAdjExecutions, sut.edgeCount)
        
        preorderVisited.removeAll()
        postorderVisited.removeAll()
        countOfAdjExecutions = 0
        
        whenIsConnectedUndirectedGraph()
        sut.breadthFirstSearch(preOrderVertexVisit: preorder, visitingVertexAdjacency: adj, postOrderVertexVisit: postorder)
        XCTAssertEqual(countOfAdjExecutions, sut.edgeCount * 2)
    }
    
    func testBreadthFirstSearch_whenPreorderVisitVertexThrows_thenRethrows() {
        let preorder: (Int) throws -> Void = { _ in throw err }
        whenIsConnectedDirectedGraph()
        do {
            try sut.breadthFirstSearch(preOrderVertexVisit: preorder, visitingVertexAdjacency: { _, _, _ in }, postOrderVertexVisit: { _ in })
            XCTFail("Has not rethrown")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
        
        whenIsConnectedUndirectedGraph()
        do {
            try sut.breadthFirstSearch(preOrderVertexVisit: preorder, visitingVertexAdjacency: { _, _, _ in }, postOrderVertexVisit: { _ in })
            XCTFail("Has not rethrown")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
    }
    
    func testBreadthFirstSearch_whenVisitingVertexAdjacencyThrows_thenRethrows() {
        let adj: (Int, WeightedEdge<Double>, Bool) throws -> Void = { _, _, _ in
            throw err
        }
        whenIsConnectedDirectedGraph()
        do {
            try sut.breadthFirstSearch(preOrderVertexVisit: {_ in }, visitingVertexAdjacency: adj, postOrderVertexVisit: { _ in })
            XCTFail("Has not rethrown.")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
        
        whenIsConnectedUndirectedGraph()
        do {
            try sut.breadthFirstSearch(preOrderVertexVisit: {_ in }, visitingVertexAdjacency: adj, postOrderVertexVisit: { _ in })
            XCTFail("Has not rethrown.")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
    }
    
    func testBreadthFirstSearch_whenPostOrderVertexVisitThrows_thenRethrows() {
        let postorder: (Int) throws -> Void = { _ in throw err }
        whenIsConnectedDirectedGraph()
        do {
            try sut.breadthFirstSearch(preOrderVertexVisit: { _ in }, visitingVertexAdjacency: { _, _, _ in }, postOrderVertexVisit: postorder)
            XCTFail("Has not rethrown")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
        
        whenIsConnectedUndirectedGraph()
        do {
            try sut.breadthFirstSearch(preOrderVertexVisit: { _ in }, visitingVertexAdjacency: { _, _, _ in }, postOrderVertexVisit: postorder)
            XCTFail("Has not rethrown")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
    }
    
    // MARK: - visitedVertices(adopting:reachAbleFrom:_:) stoppable version tests
    func testVisitedVertices_3_whenGraphHasNoEdge_thenBodyNeverExecutesAndReturnsSetContainingSourceOnly() {
        var countOfExecutions = 0
        let body: (inout Bool, Int, WeightedEdge<Double>, Bool) -> Void = { _, _, _, _ in
            countOfExecutions += 1
        }
        let vertexCount = Int.random(in: 1..<100)
        sut = AdjacencyList(kind: .directed, vertexCount: vertexCount)
        for vertex in 0..<vertexCount {
            countOfExecutions = 0
            XCTAssertEqual(sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: vertex, body), [vertex])
            XCTAssertEqual(countOfExecutions, 0)
            
            countOfExecutions = 0
            XCTAssertEqual(sut.visitedVertices(adopting: .BreadthFirstSearch, reachableFrom: vertex, body), [vertex])
            XCTAssertEqual(countOfExecutions, 0)
        }
        
        sut = AdjacencyList(kind: .undirected, vertexCount: vertexCount)
        for vertex in 0..<vertexCount {
            countOfExecutions = 0
            XCTAssertEqual(sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: vertex, body), [vertex])
            XCTAssertEqual(countOfExecutions, 0)
            
            countOfExecutions = 0
            XCTAssertEqual(sut.visitedVertices(adopting: .BreadthFirstSearch, reachableFrom: vertex, body), [vertex])
            XCTAssertEqual(countOfExecutions, 0)
        }
    }
    
    func testVisitedVertices_3_whenEdgesInGraphAndSourceHasNoAdjacencies_thenBodyNeverExecutesAndReturnsSetContainingSourceOnly() {
        var countOfExecutions = 0
        let body: (inout Bool, Int, WeightedEdge<Double>, Bool) -> Void = { _, _, _, _ in
            countOfExecutions += 1
        }
        whenIsDirectedWithEdgesNotParallelNorSelfCycleNorTwoWaysAdjacencies()
        for vertex in 0..<sut.vertexCount where sut._adjacencies[vertex].isEmpty {
            countOfExecutions = 0
            XCTAssertEqual(sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: vertex, body), [vertex])
            XCTAssertEqual(countOfExecutions, 0)
            
            countOfExecutions = 0
            XCTAssertEqual(sut.visitedVertices(adopting: .BreadthFirstSearch, reachableFrom: vertex, body), [vertex])
            XCTAssertEqual(countOfExecutions, 0)
        }
        
        whenIsUndirectedWithEdgesNotParallelNorSelfCycle()
        for vertex in 0..<sut.vertexCount where sut._adjacencies[vertex].isEmpty {
            countOfExecutions = 0
            XCTAssertEqual(sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: vertex, body), [vertex])
            XCTAssertEqual(countOfExecutions, 0)
            
            countOfExecutions = 0
            XCTAssertEqual(sut.visitedVertices(adopting: .BreadthFirstSearch, reachableFrom: vertex, body), [vertex])
            XCTAssertEqual(countOfExecutions, 0)
        }
    }
    
    func testVisitedVertices_3_whenGraphContainsEdgesAndSourceHasAdjacencies_thenBodyExecutesAndReturnsVisitedVerticesIncludingSource() {
        var countOfExecutions = 0
        let body: (inout Bool, Int, WeightedEdge<Double>, Bool) -> Void = { _, _, _, _ in
            countOfExecutions += 1
        }
        whenIsConnectedDirectedGraph()
        for vertex in 0..<sut.vertexCount {
            countOfExecutions = 0
            XCTAssertEqual(sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: vertex, body), Set(vertex..<sut.vertexCount))
            XCTAssertEqual(countOfExecutions, sut.edgeCount - vertex)
            
            countOfExecutions = 0
            XCTAssertEqual(sut.visitedVertices(adopting: .BreadthFirstSearch, reachableFrom: vertex, body), Set(vertex..<sut.vertexCount))
            XCTAssertEqual(countOfExecutions, sut.edgeCount - vertex)
        }
        
        whenIsConnectedUndirectedGraph()
        for vertex in 0..<sut.vertexCount {
            countOfExecutions = 0
            XCTAssertEqual(sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: vertex, body), Set(0..<sut.vertexCount))
            XCTAssertEqual(countOfExecutions, sut.edgeCount * 2)
            
            countOfExecutions = 0
            XCTAssertEqual(sut.visitedVertices(adopting: .BreadthFirstSearch, reachableFrom: vertex, body), Set(0..<sut.vertexCount))
            XCTAssertEqual(countOfExecutions, sut.edgeCount * 2)
        }
    }
    
    func testVisitedVertices_3_whenStopIsSetToTrueInBody_thenTraversalIsInterrupted() {
        var vertexCount = 0
        let body: (inout Bool, Int, WeightedEdge<Double>, Bool) -> Void = { stop, vertex, _, _ in
            if vertex == vertexCount / 2 {
                stop = true
            }
        }
        
        whenIsConnectedDirectedGraph()
        vertexCount = sut.vertexCount
        var visited = sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: 0, body)
        XCTAssertEqual(visited, Set(0...(sut.vertexCount / 2 + 1)))
        visited = sut.visitedVertices(adopting: .BreadthFirstSearch, reachableFrom: 0, body)
        XCTAssertEqual(visited, Set(0...(sut.vertexCount / 2 + 1)))
        
        whenIsConnectedUndirectedGraph()
        vertexCount = sut.vertexCount
        visited = sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: 0, body)
        XCTAssertEqual(visited, Set(0...(sut.vertexCount / 2)))
        visited = sut.visitedVertices(adopting: .BreadthFirstSearch, reachableFrom: 0, body)
        XCTAssertEqual(visited, Set(0...(sut.vertexCount / 2)))
    }
    
    func testVisitedVertices_3_whenBodyThorws_ThenRethrows() {
        let body: (inout Bool, Int, WeightedEdge<Double>, Bool) throws -> Void = { _, _ ,_ ,_ in
            throw err
        }
        whenIsConnectedDirectedGraph()
        do {
            let _ = try sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: 0, body)
            XCTFail("Didn't rethrow.")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
        do {
            let _ = try sut.visitedVertices(adopting: .BreadthFirstSearch, reachableFrom: 0, body)
            XCTFail("Didn't rethrow.")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
        
        whenIsConnectedUndirectedGraph()
        do {
            let _ = try sut.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: 0, body)
            XCTFail("Didn't rethrow.")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
        do {
            let _ = try sut.visitedVertices(adopting: .BreadthFirstSearch, reachableFrom: 0, body)
            XCTFail("Didn't rethrow.")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
    }
    
    // MARK: - Internal traverse helpers tests
    // These methods are just tested for checking that the traversal
    // of the graph is done correctly. Other things are tested on public
    // methods tests done earlier, that is the public methods rely
    // on these internal helper methods.
    func testRecursiveDFSOnAdiacentEdges_graphDirected() {
        var visited: Set<Int> = []
        var adjacenciesVisited: Array<Int> = []
        let body: (Int, WeightedEdge<Double>) -> Void  = { vertex, edge in
            let other = edge.other(vertex)
            adjacenciesVisited.append(other)
        }
        sut = AdjacencyList(kind: .directed, edges: givenEdgesForTraversalTests())
        let expectedResult = [3, 4, 5, 7, 8, 9, 6, 1, 2]
        sut.recursiveDFS(reachableFrom: 0, visited: &visited, body)
        XCTAssertEqual(visited, Set(0..<10))
        XCTAssertEqual(adjacenciesVisited, expectedResult)
    }
    
    func testRecursiveDFSOnAdjacencientEdges_graphUndirected() {
        var visited: Set<Int> = []
        var adjacenciesVisited: Array<Int> = []
        let body: (Int, WeightedEdge<Double>) -> Void  = { vertex, edge in
            let other = edge.other(vertex)
            adjacenciesVisited.append(other)
        }
        sut = AdjacencyList(kind: .undirected, edges: givenEdgesForTraversalTests())
        let expectedResult = [3, 4, 5, 7, 8, 9, 6, 1, 2]
        sut.recursiveDFS(reachableFrom: 0, visited: &visited, body)
        XCTAssertEqual(visited, Set(0..<10))
        XCTAssertEqual(adjacenciesVisited, expectedResult)
    }
    
    func testRecursiveDFSOnAdjacentVertices_graphDirected() {
        var visited: Set<Int> = []
        var adjacenciesVisited: Array<Int> = []
        let body: (Int) -> Void  = { adjacenciesVisited.append($0) }
        sut = AdjacencyList(kind: .directed, edges: givenEdgesForTraversalTests())
        let expectedResult = [0, 3, 4, 5, 7, 8, 9, 6, 1, 2]
        sut.recursiveDFS(reachableFrom: 0, visited: &visited, body)
        XCTAssertEqual(visited, Set(0..<10))
        XCTAssertEqual(adjacenciesVisited, expectedResult)
    }
    
    func testRecursiveDFSOnAdjacentVertices_graphUndirected() {
        var visited: Set<Int> = []
        var adjacenciesVisited: Array<Int> = []
        let body: (Int) -> Void  = { adjacenciesVisited.append($0) }
        sut = AdjacencyList(kind: .undirected, edges: givenEdgesForTraversalTests())
        let expectedResult = [0, 3, 4, 5, 7, 8, 9, 6, 1, 2]
        sut.recursiveDFS(reachableFrom: 0, visited: &visited, body)
        XCTAssertEqual(visited, Set(0..<10))
        XCTAssertEqual(adjacenciesVisited, expectedResult)
    }
    
    func testRecursiveDFSOrdersAndAdjacencies_graphDirected() {
        var visited: Set<Int> = []
        sut = AdjacencyList(kind: .directed, edges: givenEdgesForTraversalTests())
        var preorderVisited = Array<Int>()
        var postOrderVisited = Array<Int>()
        sut.recursiveDFS(
            reachableFrom: 0,
            visited: &visited,
            preOrderVertexVisit: { preorderVisited.append($0) },
            visitingVertexAdjacency: { vertex, edge, hasBeenVisited in
                XCTAssertFalse(postOrderVisited.contains(vertex))
                let other = edge.other(vertex)
                XCTAssertEqual(preorderVisited.contains(other), hasBeenVisited)
            },
            postOrderVertexVisit: { postOrderVisited.append($0) }
        )
        XCTAssertEqual(preorderVisited, [0, 3, 4, 5, 7, 8, 9, 6, 1, 2])
        XCTAssertEqual(postOrderVisited, [9, 8, 7, 5, 4, 6, 3, 2, 1, 0])
    }
    
    func testRecursiveDFSOrdersAndAdjacencies_graphUndirected() {
        var visited: Set<Int> = []
        sut = AdjacencyList(kind: .undirected, edges: givenEdgesForTraversalTests())
        var preorderVisited = Array<Int>()
        var postOrderVisited = Array<Int>()
        sut.recursiveDFS(
            reachableFrom: 0,
            visited: &visited,
            preOrderVertexVisit: { preorderVisited.append($0) },
            visitingVertexAdjacency: { vertex, edge, hasBeenVisited in
                XCTAssertFalse(postOrderVisited.contains(vertex))
                let other = edge.other(vertex)
                XCTAssertEqual(preorderVisited.contains(other), hasBeenVisited)
            },
            postOrderVertexVisit: { postOrderVisited.append($0) }
        )
        XCTAssertEqual(preorderVisited, [0, 3, 4, 5, 7, 8, 9, 6, 1, 2])
        XCTAssertEqual(postOrderVisited, [9, 8, 7, 5, 4, 6, 3, 2, 1, 0])
    }
    
    func testRecursiveDFS_StopVertexAdjacencyHasBeenVisited_graphDirected() {
        var visited: Set<Int> = []
        var verticesOrder: Array<Int> = []
        sut = AdjacencyList(kind: .directed, edges: givenEdgesForTraversalTests())
        sut.recursiveDFS(reachableFrom: 0, visited: &visited, { _, vertex, _, _ in
            verticesOrder.append(vertex)
        })
        XCTAssertEqual(verticesOrder, [0, 3, 4, 5, 7, 8, 3, 0, 1])
    }
    
    func testRecursiveDFS_StopVertexAdjacencyHasBeenVisited_graphUndirected() {
        var visited: Set<Int> = []
        var verticesOrder: Array<Int> = []
        sut = AdjacencyList(kind: .undirected, edges: givenEdgesForTraversalTests())
        sut.recursiveDFS(reachableFrom: 0, visited: &visited, { _, vertex, _, _ in
            verticesOrder.append(vertex)
        })
        XCTAssertEqual(verticesOrder, [0, 3, 3, 4, 4, 5, 5, 7, 7, 8, 8, 9, 3, 6, 0, 1, 1, 2])
    }
    
    func testIterativeBFSOnAdjacentEdges_graphDirected() {
        var visited: Set<Int> = []
        var adjacenciesVisited: Array<Int> = []
        let body: (Int, WeightedEdge<Double>) -> Void  = { vertex, edge in
            let other = edge.other(vertex)
            adjacenciesVisited.append(other)
        }
        sut = AdjacencyList(kind: .directed, edges: givenEdgesForTraversalTests())
        let expectedResult = [3, 1, 4, 6, 2, 5, 7, 8, 9]
        sut.iterativeBFS(reachableFrom: 0, visited: &visited, body)
        XCTAssertEqual(visited, Set(0..<10))
        XCTAssertEqual(adjacenciesVisited, expectedResult)
    }
    
    func testIterativeBFSOnAdjacentEdges_graphUndirected() {
        var visited: Set<Int> = []
        var adjacenciesVisited: Array<Int> = []
        let body: (Int, WeightedEdge<Double>) -> Void  = { vertex, edge in
            let other = edge.other(vertex)
            adjacenciesVisited.append(other)
        }
        sut = AdjacencyList(kind: .undirected, edges: givenEdgesForTraversalTests())
        let expectedResult = [3, 1, 4, 6, 2, 5, 7, 8, 9]
        sut.iterativeBFS(reachableFrom: 0, visited: &visited, body)
        XCTAssertEqual(visited, Set(0..<10))
        XCTAssertEqual(adjacenciesVisited, expectedResult)
    }
    
    func testIterativeBFSOnAdjacentVertices_graphDirected() {
        var visited: Set<Int> = []
        var adjacenciesVisited: Array<Int> = []
        let body: (Int) -> Void  = { adjacenciesVisited.append($0) }
        sut = AdjacencyList(kind: .directed, edges: givenEdgesForTraversalTests())
        let expectedResult = [0, 3, 1, 4, 6, 2, 5, 7, 8, 9]
        sut.iterativeBFS(reachableFrom: 0, visited: &visited, body)
        XCTAssertEqual(visited, Set(0..<10))
        XCTAssertEqual(adjacenciesVisited, expectedResult)
    }
    
    func testIterativeBFSOnAdjacentVertices_graphUndirected() {
        var visited: Set<Int> = []
        var adjacenciesVisited: Array<Int> = []
        let body: (Int) -> Void  = { adjacenciesVisited.append($0) }
        sut = AdjacencyList(kind: .undirected, edges: givenEdgesForTraversalTests())
        let expectedResult = [0, 3, 1, 4, 6, 2, 5, 7, 8, 9]
        sut.iterativeBFS(reachableFrom: 0, visited: &visited, body)
        XCTAssertEqual(visited, Set(0..<10))
        XCTAssertEqual(adjacenciesVisited, expectedResult)
    }
    
    func testIterativeBFS_StopVertexAdjacencyHasBeenVisited_graphDirected() {
        var visited: Set<Int> = []
        var verticesOrder: Array<Int> = []
        sut = AdjacencyList(kind: .directed, edges: givenEdgesForTraversalTests())
        sut.iterativeBFS(reachableFrom: 0, visited: &visited, { _, vertex, _, _ in
            verticesOrder.append(vertex)
        })
        XCTAssertEqual(verticesOrder, [0, 0, 3, 3, 1, 4, 5, 7, 8])
    }
    
    func testIterativeBFS_StopVertexAdjacencyHasBeenVisited_graphUndirected() {
        var visited: Set<Int> = []
        var verticesOrder: Array<Int> = []
        sut = AdjacencyList(kind: .undirected, edges: givenEdgesForTraversalTests())
        sut.iterativeBFS(reachableFrom: 0, visited: &visited, { _, vertex, _, _ in
            verticesOrder.append(vertex)
        })
        XCTAssertEqual(verticesOrder, [0, 0, 3, 3, 3, 1, 1, 4, 4, 6, 2, 5, 5, 7, 7, 8, 8, 9])
    }
    
}

