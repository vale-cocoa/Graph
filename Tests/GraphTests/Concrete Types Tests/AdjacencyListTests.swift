//
//  AdjacencyListTests.swift
//  GraphTests
//
//  Created by Valeriano Della Longa on 2021/04/27.
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

final class AdjacencyListTests: GraphBaseTests {
    // MARK: - Graph conformance tests
    // MARK: - init(kind:edges:) tests
    func testInitKindEdges_whenEdgesIsEmpty() {
        let kind = (Int.random(in: 1...100) % 2) == 0 ? GraphConnections.undirected : GraphConnections.directed
        
        sut = AdjacencyList(kind: kind, edges: [])
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.kind, kind)
        XCTAssertEqual(sut.vertexCount, 0)
        XCTAssertTrue(sut._adjacencies.isEmpty)
    }
    
    func testInitKindEdges_whenKindIsUndirected_edgesContainsDistinctUndirectedEdges() {
        let e1Vertices = givenTwoRandomAndDistinctVertices
        let e1Weight = Double.random(in: 0.5..<10.5)
        let e1 = WeightedEdge(vertices: e1Vertices, weight: e1Weight)
        let e2Vertices = (e1Vertices.0 + 100, e1Vertices.1 + 200)
        let e2Weight = Double.random(in: 0.5..<10.5)
        let e2 = WeightedEdge(vertices: e2Vertices, weight: e2Weight)
        let edges = [e1, e2]
        let expectedVertexCount = edges.map({ Swift.max($0.v, $0.w) }).max()! + 1
        
        sut = AdjacencyList(kind: .undirected, edges: edges)
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.vertexCount, expectedVertexCount)
        XCTAssertEqual(sut._adjacencies.count, sut.vertexCount)
        XCTAssertEqual(sut.edgeCount, 2)
        
        var vertex = e1.either
        XCTAssertEqual(sut._adjacencies[vertex], [e1])
        var other = e1.other(vertex)
        XCTAssertEqual(sut._adjacencies[other], [e1.reversed()])
        
        vertex = e2.either
        XCTAssertEqual(sut._adjacencies[vertex], [e2])
        other = e2.other(vertex)
        XCTAssertEqual(sut._adjacencies[other], [e2.reversed()])
    }
    
    func testInitKindEdges_whenKindIsUndirected_edgesContainsSameUndirectedEdges() {
        let vertices = givenTwoRandomAndDistinctVertices
        let vertex = vertices.0
        let other = vertices.1
        let e1Weight = Double.random(in: 0.5..<10.5)
        let e1 = WeightedEdge(vertices: vertices, weight: e1Weight)
        let e2Weight = Double.random(in: 0.5..<10.5)
        let e2 = e1.reversedWith(weight: e2Weight)
        let edges = [e1, e2]
        let expectedVertexCount = edges.map({ Swift.max($0.v, $0.w) }).max()! + 1
        
        sut = AdjacencyList(kind: .undirected, edges: edges)
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.vertexCount, expectedVertexCount)
        XCTAssertEqual(sut._adjacencies.count, sut.vertexCount)
        XCTAssertEqual(sut.edgeCount, 2)
        XCTAssertEqual(sut._adjacencies[vertex], [e1, e2.reversed()])
        XCTAssertEqual(sut._adjacencies[other], [e1.reversed(), e2])
    }
    
    func testInitKindEdges_whenKindIsDirected_edgesContainsDistinctDirectedEdges() {
        let e1Vertices = givenTwoRandomAndDistinctVertices
        let e1Weight = Double.random(in: 0.5..<10.5)
        let e1 = WeightedEdge(vertices: e1Vertices, weight: e1Weight)
        let e2Vertices = (e1Vertices.0 + 200, e1Vertices.1 + 300)
        let e2Weight = Double.random(in: 0.5..<10.5)
        let e2 = WeightedEdge(vertices: e2Vertices, weight: e2Weight)
        let edges = [e1, e2]
        let expectedVertexCount = edges.map({ Swift.max($0.v, $0.w) }).max()! + 1
        
        sut = AdjacencyList(kind: .directed, edges: edges)
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.vertexCount, expectedVertexCount)
        XCTAssertEqual(sut._adjacencies.count, sut.vertexCount)
        XCTAssertEqual(sut.edgeCount, 2)
        XCTAssertEqual(sut._adjacencies[e1.tail], [e1])
        XCTAssertEqual(sut._adjacencies[e2.tail], [e2])
    }
    
    func testInitKindEdges_whenKindIsDirected_edgesContainsEdgesReverseOfOneAnother() {
        let vertices = givenTwoRandomAndDistinctVertices
        let vertex = vertices.0
        let other = vertices.1
        let e1Weight = Double.random(in: 0.5..<10.5)
        let e1 = WeightedEdge(tail: vertex, head: other, weight: e1Weight)
        let e2 = e1.reversed()
        let edges = [e1, e2]
        let expectedVertexCount = edges.map({ Swift.max($0.v, $0.w) }).max()! + 1
        
        sut = AdjacencyList(kind: .directed, edges: edges)
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.vertexCount, expectedVertexCount)
        XCTAssertEqual(sut._adjacencies.count, sut.vertexCount)
        XCTAssertEqual(sut.edgeCount, 2)
        XCTAssertEqual(sut._adjacencies[vertex], [e1])
        XCTAssertEqual(sut._adjacencies[other], [e2])
    }
    
    // MARK: - adjacencies(vertex:) tests
    func testAdjacenciesVertex_whenEdgeCountIsZero_thenReturnsEmptyArrayForEveryVertex() {
        XCTAssertEqual(sut.edgeCount, 0)
        for vertex in 0..<sut.vertexCount {
            XCTAssertTrue(sut.adjacencies(vertex: vertex).isEmpty)
        }
    }
    
    func testAdjacenciesVertex_whenKindIsUndirectedAndContainsEdges() {
        whenKindIsUndirectedAndContainsEdges()
        for vertex in 0..<sut.vertexCount {
            let edges = sut.adjacencies(vertex: vertex)
            for edge in edges {
                let other = edge.other(vertex)
                XCTAssertNotNil(sut.adjacencies(vertex: other).first(where:{ $0 <=~=> edge }))
            }
        }
    }
    
    func testAdjacenciesVertex_whenKindIsDirectedAndContainsEdges() {
        whenKindIsDirectedAndContainsEdges()
        for vertex in 0..<sut.vertexCount {
            let edges = sut.adjacencies(vertex: vertex)
            for edge in edges where edge.tail != edge.head {
                XCTAssertNil(sut.adjacencies(vertex: edge.head).first(where: { $0 <=~=> edge }))
            }
        }
    }
    
    // MARK: - reversed() tests
    func testReversed_whenKindIsUndirectedAndContainsEdges() {
        whenKindIsUndirectedAndContainsEdges()
        let reversed = sut.reversed()
       
        XCTAssertEqual(sut, reversed)
    }
    
    func testReversed_whenKindIsDirectdAndContainsEdges() {
        whenKindIsDirectedAndContainsEdges()
        let reversed = sut.reversed()
        
        XCTAssertEqual(reversed.vertexCount, sut.vertexCount)
        XCTAssertEqual(reversed.edgeCount, sut.edgeCount)
        var originalAdjacencies = sut._adjacencies
        for vertex in 0..<reversed.vertexCount {
            let edges = reversed.adjacencies(vertex: vertex)
            for edge in edges {
                if
                    let idxToRemove = originalAdjacencies[edge.head]
                        .firstIndex(of: edge.reversed())
                {
                    originalAdjacencies[edge.head].remove(at: idxToRemove)
                } else {
                    XCTFail("Did not found reveresed edge: \(edge) in original adjacencies.")
                }
            }
        }
        XCTAssertTrue(originalAdjacencies.allSatisfy({ $0.isEmpty }))
    }
    
    // MARK: - MutableGraph conformance tests
    // MARK: - init(kind:vertexCount:) tests
    func testInitKindVertexCount() {
        let vertexCount = Int.random(in: 1..<100)
        let kind = (Int.random(in: 1...100) % 2) == 0 ? GraphConnections.undirected : GraphConnections.directed
        
        sut = AdjacencyList(kind: kind, vertexCount: vertexCount)
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.kind, kind)
        XCTAssertEqual(sut.vertexCount, vertexCount)
        XCTAssertEqual(sut.edgeCount, 0)
        XCTAssertEqual(sut._adjacencies.count, vertexCount)
        XCTAssertTrue(sut._adjacencies.allSatisfy({ $0.isEmpty }))
    }
    
    // MARK: - add(edge:) tests
    func testAddEdgeOnUndirected_whenEdgeIsNotSelfLoop() {
        whenKindIsUndirectedAndContainsEdges()
        let vertex = Int.random(in: 0..<(sut.vertexCount / 2))
        let other = Int.random(in: (sut.vertexCount / 2)..<sut.vertexCount)
        let edge = WeightedEdge(vertices: (vertex, other), weight: Double.random(in: 0.5..<10.5))
        let expectedEdgeCount = sut.edgeCount + 1
        
        sut.add(edge: edge)
        XCTAssertEqual(sut.edgeCount, expectedEdgeCount)
        XCTAssertEqual(sut.adjacencies(vertex: vertex).last, edge)
        XCTAssertEqual(sut.adjacencies(vertex: other).last, edge.reversed())
    }
    
    func testAddEgeOnDirected_whenEdgeIsNotSelfLoop() {
        whenKindIsDirectedAndContainsEdges()
        let edge = WeightedEdge(tail: Int.random(in: 0..<(sut.vertexCount / 2)), head: Int.random(in: (sut.vertexCount / 2)..<sut.vertexCount), weight: Double.random(in: 0.5..<10.5))
        let expectedEdgeCount = sut.edgeCount + 1
        
        sut.add(edge: edge)
        XCTAssertEqual(sut.edgeCount, expectedEdgeCount)
        XCTAssertEqual(sut.adjacencies(vertex: edge.tail).last, edge)
    }
    
    func testAddEdgeOnUndirected_whenEdgeVerticesAreAlreadyAdjacent() throws {
        whenKindIsUndirectedAndContainsEdges()
        let existingEdge = sut._adjacencies
            .flatMap({ $0 })
            .filter({ edge in
                !edge.isSelfLoop
            })
            .randomElement()
        
        try XCTSkipIf(existingEdge == nil)
        
        let vertex = existingEdge!.either
        let other = existingEdge!.other(vertex)
        let newEdge = WeightedEdge(vertices: (vertex, other), weight: existingEdge!.weight + 10.0 )
        let expectedVertexAdjacencies = sut.adjacencies(vertex: vertex) + [newEdge]
        let expectedOtherAdjacencies = sut.adjacencies(vertex: other) + [newEdge.reversed()]
        let expectedEdgeCount = sut.edgeCount + 1
        
        sut.add(edge: newEdge)
        XCTAssertEqual(sut.edgeCount, expectedEdgeCount)
        XCTAssertEqual(sut.adjacencies(vertex: vertex), expectedVertexAdjacencies)
        XCTAssertEqual(sut.adjacencies(vertex: other), expectedOtherAdjacencies)
    }
    
    func testAddEdgeOnDirected_whenEdgeVerticesAreAlreadyAdjacent() {
        whenKindIsDirectedAndContainsEdges()
        let existingEdge = sut._adjacencies.flatMap({ $0 }).randomElement()!
        let newEdge = WeightedEdge(tail: existingEdge.tail, head: existingEdge.head, weight: 100.0)
        let expectedVertexAdjacencies = sut.adjacencies(vertex: existingEdge.tail) + [newEdge]
        let expectedEdgeCount = sut.edgeCount + 1
        
        sut.add(edge: newEdge)
        XCTAssertEqual(sut.edgeCount, expectedEdgeCount)
        XCTAssertEqual(sut.adjacencies(vertex: existingEdge.tail), expectedVertexAdjacencies)
    }
    
    func testAddEdge_whenKindIsUndirectedAndEdgeIsSelfLoop() {
        whenKindIsUndirectedAndContainsEdges()
        let vertex = Int.random(in: 0..<sut.vertexCount)
        let edge = WeightedEdge(vertices: (vertex, vertex), weight: Double.random(in: 0.5..<10.5))
        let expectedVertexAdjacencies = sut._adjacencies[vertex] + [edge, edge.reversed()]
        let expectedEdgeCount = sut.edgeCount + 1
        
        sut.add(edge: edge)
        XCTAssertEqual(sut.edgeCount, expectedEdgeCount)
        XCTAssertEqual(sut.adjacencies(vertex: edge.either), expectedVertexAdjacencies)
    }
    
    func testAddEdge_whenKindIsDirectedAndEdgeIsSelfLoop() {
        whenKindIsDirectedAndContainsEdges()
        let vertex = Int.random(in: 0..<sut.vertexCount)
        let edge = WeightedEdge(vertices: (vertex, vertex), weight: Double.random(in: 0.5..<10.5))
        let expectedVertexAdjacencies = sut._adjacencies[vertex] + [edge]
        let expectedEdgeCount = sut.edgeCount + 1
        
        sut.add(edge: edge)
        XCTAssertEqual(sut.edgeCount, expectedEdgeCount)
        XCTAssertEqual(sut.adjacencies(vertex: edge.either), expectedVertexAdjacencies)
    }
    
    // MARK: - remove(edge:) tests
    func testRemoveEdgeOnUndirectedAndDirected_whenEdgeNotInGraph() throws {
        whenKindIsUndirectedAndContainsEdges()
        var disconnectedVertex = (0..<sut.vertexCount)
            .first(where: { sut.adjacencies(vertex: $0).isEmpty })
        
        try XCTSkipIf(disconnectedVertex == nil)
        
        var otherVertex = Int.random(in: 0..<sut.vertexCount)
        var notExistingEdge = WeightedEdge(tail: disconnectedVertex!, head: otherVertex, weight: 100.0)
        var prevEdgeCount = sut.edgeCount
        XCTAssertFalse(sut.remove(edge: notExistingEdge))
        XCTAssertEqual(sut.edgeCount, prevEdgeCount)
        
        notExistingEdge = sut._adjacencies
            .flatMap({$0})
            .randomElement()!
            .reversedWith(weight: 100.0)
        XCTAssertFalse(sut.remove(edge: notExistingEdge))
        XCTAssertEqual(sut.edgeCount, prevEdgeCount)
        
        whenKindIsDirectedAndContainsEdges()
        disconnectedVertex = (0..<sut.vertexCount)
            .first(where: { sut.adjacencies(vertex: $0).isEmpty })
        
        try XCTSkipIf(disconnectedVertex == nil)
        
        otherVertex = Int.random(in: 0..<sut.vertexCount)
        notExistingEdge = WeightedEdge(tail: disconnectedVertex!, head: otherVertex, weight: 100.0)
        prevEdgeCount = sut.edgeCount
        XCTAssertFalse(sut.remove(edge: notExistingEdge))
        XCTAssertEqual(sut.edgeCount, prevEdgeCount)
    }
    
    func testRemoveEdgeOnUndirected_whenEdgeIsInGraphAndNotSelfLoop() throws {
        whenKindIsUndirectedAndContainsEdges()
        let edgeToRemove = sut._adjacencies
            .flatMap({ $0 })
            .filter({ edge in
                !edge.isSelfLoop
            })
            .randomElement()
        
        try XCTSkipIf(edgeToRemove == nil)
        
        let vertex = edgeToRemove!.either
        let otherVertex = edgeToRemove!.other(vertex)
        var expectedVertexAdj = sut.adjacencies(vertex: vertex)
        var idxToRemove = expectedVertexAdj.firstIndex(where: { $0 == edgeToRemove })!
        expectedVertexAdj.remove(at: idxToRemove)
        var expectedOtherVertexAdj = sut.adjacencies(vertex: otherVertex)
        idxToRemove = expectedOtherVertexAdj.firstIndex(where: { $0 == edgeToRemove!.reversed() })!
        expectedOtherVertexAdj.remove(at: idxToRemove)
        let expectedEdgeCount = sut.edgeCount - 1
        
        XCTAssertTrue(sut.remove(edge: edgeToRemove!))
        XCTAssertEqual(sut.edgeCount, expectedEdgeCount)
        XCTAssertEqual(sut.adjacencies(vertex: vertex), expectedVertexAdj)
        XCTAssertEqual(sut.adjacencies(vertex: otherVertex), expectedOtherVertexAdj)
    }
    
    func testRemoveEdgeOnUndirected_whenEdgeHasParallelEdgeInGraph() {
        whenKindIsUndirected()
        let vertex = Int.random(in: 0..<(sut.vertexCount / 2))
        let other = Int.random(in: (sut.vertexCount / 2)..<sut.vertexCount)
        let weight = Double.random(in: 0.5..<10.5)
        let edge = WeightedEdge(vertices: (vertex, other), weight: weight)
        let parallelEdge = WeightedEdge(vertices: (vertex, other), weight: weight + 10.0)
        sut.add(edge: parallelEdge)
        sut.add(edge: edge)
        let expectedEdgeCount = sut.edgeCount - 1
        
        XCTAssertTrue(sut.remove(edge: edge))
        XCTAssertEqual(sut.edgeCount, expectedEdgeCount)
        XCTAssertEqual(sut.adjacencies(vertex: vertex), [parallelEdge])
        XCTAssertEqual(sut.adjacencies(vertex: other), [parallelEdge.reversed()])
    }
    
    func testRemoveEdgeOnUndirected_whenEdgeIsInGraphAndIsSelfLoop() {
        whenKindIsUndirected()
        let weight = Double.random(in: 0.5..<10.5)
        let vertex = Int.random(in: 0..<sut.vertexCount)
        let edge = WeightedEdge(vertices: (vertex, vertex), weight: weight)
        sut.add(edge: edge)
        let expectedEdgeCount = sut.edgeCount - 1
        
        XCTAssertTrue(sut.remove(edge: edge))
        XCTAssertEqual(sut.edgeCount, expectedEdgeCount)
        XCTAssertEqual(sut.adjacencies(vertex: vertex), [])
    }
    
    func testRemoveEdgeOnDirected_whenEdgeIsInGraphAndNotSelfLoop() throws {
        whenKindIsDirectedAndContainsEdges()
        let edgeToRemove = sut._adjacencies
            .flatMap({ $0 })
            .filter({ edge in
                !edge.isSelfLoop
            })
            .randomElement()
        
        try XCTSkipIf(edgeToRemove == nil)
        
        var expectedVertexAdjacency = sut.adjacencies(vertex: edgeToRemove!.tail)
        let idxToRemove = expectedVertexAdjacency.firstIndex(of: edgeToRemove!)!
        expectedVertexAdjacency.remove(at: idxToRemove)
        let expectedEdgeCount = sut.edgeCount - 1
        
        XCTAssertTrue(sut.remove(edge: edgeToRemove!))
        XCTAssertEqual(sut.edgeCount, expectedEdgeCount)
        XCTAssertEqual(sut.adjacencies(vertex: edgeToRemove!.tail), expectedVertexAdjacency)
    }
    
    func testRemoveEdgeOnDirected_whenEdgeHasParallelEdgeInGraph() {
        whenKindIsDirected()
        let tail = Int.random(in: 0..<(sut.vertexCount / 2))
        let head = Int.random(in: (sut.vertexCount / 2)..<sut.vertexCount)
        let weight = Double.random(in: 0.5..<10.5)
        let edge = WeightedEdge(tail: tail, head: head, weight: weight)
        let parallelEdge = WeightedEdge(tail: tail, head: head, weight: weight + 10.0)
        sut.add(edge: parallelEdge)
        sut.add(edge: edge)
        let expectedEdgeCount = sut.edgeCount - 1
        
        XCTAssertTrue(sut.remove(edge: edge))
        XCTAssertEqual(sut.edgeCount, expectedEdgeCount)
        XCTAssertEqual(sut.adjacencies(vertex: edge.tail), [parallelEdge])
    }
    
    func testRemoveEdgeOnDirected_whenEdgeIsInGraphAndSelfLoop() {
        whenKindIsDirected()
        let vertex = Int.random(in: 0..<sut.vertexCount)
        let weight = Double.random(in: 0.5..<10.5)
        let edge = WeightedEdge(tail: vertex, head: vertex, weight: weight)
        sut.add(edge: edge)
        let expectedEdgeCount = sut.edgeCount - 1
        
        XCTAssertTrue(sut.remove(edge: edge))
        XCTAssertEqual(sut.edgeCount, expectedEdgeCount)
        XCTAssertEqual(sut.adjacencies(vertex: vertex), [])
    }
    
    // MARK: - removeAllEdges() tests
    func testRemoveAllEdgesOnDirectedAndUndirected() {
        whenKindIsDirectedAndContainsEdges()
        sut.removeAllEdges()
        XCTAssertEqual(sut.edgeCount, 0)
        XCTAssertEqual(sut._adjacencies.count, sut.vertexCount)
        XCTAssertTrue(sut._adjacencies.allSatisfy({ $0.isEmpty }))
        
        whenKindIsUndirectedAndContainsEdges()
        sut.removeAllEdges()
        XCTAssertEqual(sut.edgeCount, 0)
        XCTAssertEqual(sut._adjacencies.count, sut.vertexCount)
        XCTAssertTrue(sut._adjacencies.allSatisfy({ $0.isEmpty }))
    }
    
    // MARK: - reverse() tests
    func testReverseOnUndirected() {
        whenKindIsUndirectedAndContainsEdges()
        let expectedResult = sut
        sut.reverse()
        
        XCTAssertEqual(sut, expectedResult)
    }
    
    func testReverseOnDirected() {
        whenKindIsDirectedAndContainsEdges()
        let expectedResult = sut.reversed()
        sut.reverse()
        
        XCTAssertEqual(sut, expectedResult)
    }
    
    // MARK: - Codable conformance tests
    func testEncodeDecode() {
        whenKindIsDirectedAndContainsEdges()
        do {
            let data = try JSONEncoder().encode(sut)
            let decoded = try JSONDecoder().decode(AdjacencyList<WeightedEdge<Double>>.self, from: data)
            assertAreEquivalent(lhs: decoded, rhs: sut)
        } catch {
            XCTFail("Encoding/Decoding has thrown error.")
        }
        
        whenKindIsUndirectedAndContainsEdges()
        do {
            let data = try JSONEncoder().encode(sut)
            let decoded = try JSONDecoder().decode(AdjacencyList<WeightedEdge<Double>>.self, from: data)
            assertAreEquivalent(lhs: decoded, rhs: sut)
        } catch {
            XCTFail("Encoding/Decoding has thrown error.")
        }
    }
    
    func testDecode_whenNegativeVertexCount_thenThrows() {
        do {
            let _ = try JSONDecoder().decode(AdjacencyList<WeightedEdge<Double>>.self, from: negativeVertexCountAdjacencyListData)
            XCTFail("Has not thrown error.")
        } catch {
            XCTAssertEqual(error as NSError, AdjacencyList<WeightedEdge<Double>>.Error.decodedVertexCountNegative as NSError)
        }
    }
    
    func testDecode_whenOutOfBoundsEdge_thenThrows() {
        do {
            let _ = try JSONDecoder().decode(AdjacencyList<WeightedEdge<Double>>.self, from: outOfBoundsAdjacencyListData)
            XCTFail("Has not thrown error.")
        } catch {
            XCTAssertEqual(error as NSError, AdjacencyList<WeightedEdge<Double>>.Error.decodedEdgeOutBounds as NSError)
        }
    }
    
}
