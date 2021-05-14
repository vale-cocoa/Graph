//
//  TestsHelpers.swift
//  GraphTests
//
//  Created by Valeriano Della Longa on 2021/04/30.
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

// MARK: - Useful values for tests
let err: NSError = NSError(domain: "com.vdl.graph", code: 1, userInfo: nil)

func outOfBoundsEdgeJSON(vertexCount: Int) -> [String : Any] {
    let v = Int.random(in: 0..<vertexCount)
    let w = vertexCount
    let weight = Double.random(in: 0.5..<10.5)
    
    return [
        "v" : v as Any,
        "w" : w as Any,
        "weight": weight as Any
    ]
}

func inBoundsEdgeJSON(vertexCount: Int) -> [String : Any] {
    let v = Int.random(in: 0..<(vertexCount / 2))
    let w = Int.random(in: (vertexCount / 2)..<vertexCount)
    let weight = Double.random(in: 0.5..<10.5)
    
    return [
        "v" : v as Any,
        "w" : w as Any,
        "weight": weight as Any
    ]
}

let outOfBoundsAdjacencyListData: Data = {
    let vertexCount = Int.random(in: 20..<100)
    var edges = Array<[String : Any]>()
    edges.append(outOfBoundsEdgeJSON(vertexCount: vertexCount))
    let edgeCount = vertexCount / 2
    for _ in 1..<edgeCount {
        edges.append(inBoundsEdgeJSON(vertexCount: vertexCount))
    }
    edges.shuffle()
    
    let kv = [
        "kind" : (["graphConnectionType" : "directed"] as Any),
        "vertexCount" : vertexCount,
        "edges" : edges as Any
    ]
    
    return try! JSONSerialization.data(withJSONObject: kv, options: .prettyPrinted)
}()

let negativeVertexCountAdjacencyListData: Data = {
    let vertexCount = Int.random(in: -100..<0)
    let kv = [
        "kind" : (["graphConnectionType" : "directed"] as Any),
        "vertexCount" : vertexCount,
        "edges" : [] as Any
    ]
    
    return try! JSONSerialization.data(withJSONObject: kv, options: .prettyPrinted)
}()

// MARK: - GIVEN
var givenTwoRandomAndDistinctVertices: (v: Int, w: Int ) { (Int.random(in: 0..<10), Int.random(in: 10..<20)) }

func givenRandomWeightedEdges(minimumVertexCount: Int = 10) -> [WeightedEdge<Double>] {
    let countOfVertex = Int.random(in: minimumVertexCount..<100)
    let countOfEdge = (countOfVertex / 2)
    var edges = [WeightedEdge<Double>]()
    for _ in 0..<countOfEdge {
        let tail = Int.random(in: 0..<countOfVertex)
        let head = Int.random(in: 0..<countOfVertex)
        let weight = Double.random(in: 0.5..<10.5)
        let edge = WeightedEdge(tail: tail, head: head, weight: weight)
        edges.append(edge)
    }
    
    return edges
}

func givenEdgesNotParallelNorSelfCycleNorTwoWaysAdjacencies(vertexCount: Int = 100) -> [WeightedEdge<Double>] {
    let vertexCount = 100
    var edges = Array<WeightedEdge<Double>>()
    for tail in 0..<(vertexCount / 2) {
        let weight = Double.random(in: 0.5..<10.5)
        let head = tail + (vertexCount / 2)
        edges.append(WeightedEdge(tail: tail, head: head, weight: weight))
    }
    edges.shuffle()
    edges.removeLast(Int.random(in: 0..<(vertexCount / 3)))
    
    return edges
}

func givenEdgesConnectedOneToEachOtherAscending(vertexCount: Int = Int.random(in: 10..<100)) -> [WeightedEdge<Double>] {
    var edges = Array<WeightedEdge<Double>>()
    for tail in 0..<(vertexCount - 1) {
        let weight = Double.random(in: 0.5..<10.5)
        let head = tail + 1
        edges.append(WeightedEdge(tail: tail, head: head, weight: weight))
    }
    
    return edges
}

// MARK: - Concrete type conforming to GraphEdge for tests
struct DummyGraphEdge: GraphEdge {
    let _v: Int
    
    let _w : Int
    
    init(v: Int, w: Int) {
        self._v = v
        self._w = w
    }
    
    var either: Int { _v }
    
    func other(_ vertex: Int) -> Int {
        if vertex == _v { return _w }
        if vertex == _w { return _v }
        preconditionFailure("Vertex: \(vertex) is not in edge.")
    }
    
    func reversed() -> DummyGraphEdge {
        Self(v: _w, w: _v)
    }
    
}

// MARK: - Concrete type coforming to WeightedGraphEdge for tests
struct DummyWeightedGraphEdge<T: AdditiveArithmetic & Comparable & Hashable>: WeightedGraphEdge {
    let _v: Int
    
    let _w: Int
    
    let weight: T
    
    init(v: Int, w: Int, weight: T) {
        self._v = v
        self._w = w
        self.weight = weight
    }
    
    var either: Int { _v }
    
    func other(_ vertex: Int) -> Int {
        if vertex == _v { return _w }
        if vertex == _w { return _v }
        preconditionFailure("Vertex: \(vertex) is not in edge.")
    }
    
    func reversed() -> DummyWeightedGraphEdge<T> {
        Self(v: _w, w: _v, weight: weight)
    }
    
    func reversedWith(weight: T) -> DummyWeightedGraphEdge<T> {
        Self(v: _w, w: _v, weight: weight)
    }
    
}

// MARK: - Concrete type conforming to Graph for tests
struct DummyGraph<Edge: GraphEdge>: Graph {
    let kind: GraphConnections
    
    let vertexCount: Int
    
    private(set) var edgeCount: Int = 0
    
    private var _adjacencies: Array<Array<Edge>>
    
    init(kind: GraphConnections, edges: [Edge]) {
        self.kind = kind
        guard !edges.isEmpty else {
            self.vertexCount = 0
            self._adjacencies = []
            
            return
        }
        
        self.vertexCount = edges.map({ edge in
            let vertex = edge.either
            let other = edge.other(vertex)
            
            return Swift.max(vertex, other)
        }).max()! + 1
        self._adjacencies = Array(repeating: [], count: self.vertexCount)
        edges.forEach({ edge in
            let vertex = edge.either
            self._adjacencies[vertex].append(edge)
            if kind == . undirected {
                let other = edge.other(vertex)
                self._adjacencies[other].append(edge.reversed())
            }
            self.edgeCount += 1
        })
    }
    
    private init(kind: GraphConnections, vertexCount: Int, adjacencies: Array<Array<Edge>>, edgeCount: Int) {
        self.kind = kind
        self.vertexCount = vertexCount
        self.edgeCount = edgeCount
        self._adjacencies = adjacencies
    }
    
    func adjacencies(vertex: Int) -> [Edge] {
        precondition(0..<vertexCount ~= vertex, "Vertex: \(vertex) not in graph.")
        
        return _adjacencies[vertex]
    }
    
    func reversed() -> DummyGraph<Edge> {
        guard kind == .directed else { return self }
        
        var invertedAdjacencies = Array<Array<Edge>>(repeating: [], count: vertexCount)
        for edges in _adjacencies {
            edges.forEach({
                let revEdge = $0.reversed()
                invertedAdjacencies[revEdge.tail].append(revEdge)
            })
        }
        
        return DummyGraph(kind: kind, vertexCount: vertexCount, adjacencies: invertedAdjacencies, edgeCount: edgeCount)
    }
    
}

// MARK: - Asserts
func assertAreEquivalent<T: Graph, V: Graph>(lhs: T, rhs: V, message: String = "", file: StaticString = #file, line: UInt = #line) where T.Edge == V.Edge
{
    guard
        lhs.kind == rhs.kind
    else {
        XCTFail("Different kind values lhs: \(lhs.kind), rhs: \(rhs.kind) - \(message)")
        
        return
    }
    
    guard
        lhs.vertexCount == rhs.vertexCount
    else {
        XCTFail("Different vertexCount values lhs: \(lhs.vertexCount), rhs: \(rhs.vertexCount) - \(message)")
        
        return
    }
    
    guard
        lhs.edgeCount == rhs.edgeCount
    else {
        XCTFail("Different edgeCount values lhs: \(lhs.edgeCount), rhs: \(rhs.edgeCount) - \(message)")
        
        return
    }
    
    for vertex in 0..<lhs.vertexCount {
        let lhsEdges = lhs.adjacencies(vertex: vertex)
        var rhsEdges = rhs.adjacencies(vertex: vertex)
        guard
            lhsEdges.count == rhsEdges.count
        else {
            XCTFail("Different adjacencies at vertex: \(vertex) - \(message)")
            
            return
        }
        
        for edge in lhsEdges {
            guard
                let idx = rhsEdges.firstIndex(of: edge)
            else {
                XCTFail("Different adjacencies at vertex: \(vertex) - \(message)")
                
                return
            }
            
            rhsEdges.remove(at: idx)
        }
        guard rhsEdges.isEmpty else {
            
            XCTFail("Different adjacencies at vertex: \(vertex) - \(message)")
            
            return
        }
    }
}
