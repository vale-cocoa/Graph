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
var givenTwoRandomAndDistinctVertices: (v: Int, w: Int ) { (Int.random(in: 0..<10), Int.random(in: 10..<100)) }

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

func givenTinyEWDAG() -> AdjacencyList<WeightedEdge<Double>> {
    // Set the graph to be acyclic digraph from the book Algorithms 4th edition p.658
    // with non-negative edges (tinyEWDAG.txt)
    var edges = Array<WeightedEdge<Double>>()
    
    edges.append(WeightedEdge(tail: 5, head: 4, weight: 0.35))
    edges.append(WeightedEdge(tail: 4, head: 7, weight: 0.37))
    edges.append(WeightedEdge(tail: 5, head: 7, weight: 0.28))
    edges.append(WeightedEdge(tail: 5, head: 1, weight: 0.32))
    edges.append(WeightedEdge(tail: 4, head: 0, weight: 0.38))
    edges.append(WeightedEdge(tail: 0, head: 2, weight: 0.26))
    edges.append(WeightedEdge(tail: 3, head: 7, weight: 0.39))
    edges.append(WeightedEdge(tail: 1, head: 3, weight: 0.29))
    edges.append(WeightedEdge(tail: 7, head: 2, weight: 0.34))
    edges.append(WeightedEdge(tail: 6, head: 2, weight: 0.40))
    edges.append(WeightedEdge(tail: 3, head: 6, weight: 0.52))
    edges.append(WeightedEdge(tail: 6, head: 0, weight: 0.58))
    edges.append(WeightedEdge(tail: 6, head: 4, weight: 0.93))
    
    return AdjacencyList(kind: .directed, edges: edges)
}

func givenTinyEWDn() -> AdjacencyList<WeightedEdge<Double>> {
    // Set the graph to be acyclic digraph with some negative weights
    // from the book Algorithms 4th edition p.676 (tinyEWDn.txt)
    var edges = Array<WeightedEdge<Double>>()
    
    edges.append(WeightedEdge(tail: 4, head: 5, weight: 0.35))
    edges.append(WeightedEdge(tail: 5, head: 4, weight: 0.35))
    edges.append(WeightedEdge(tail: 4, head: 7, weight: 0.37))
    edges.append(WeightedEdge(tail: 5, head: 7, weight: 0.28))
    edges.append(WeightedEdge(tail: 7, head: 5, weight: 0.28))
    edges.append(WeightedEdge(tail: 5, head: 1, weight: 0.32))
    edges.append(WeightedEdge(tail: 0, head: 4, weight: 0.38))
    edges.append(WeightedEdge(tail: 0, head: 2, weight: 0.26))
    edges.append(WeightedEdge(tail: 7, head: 3, weight: 0.39))
    edges.append(WeightedEdge(tail: 1, head: 3, weight: 0.29))
    edges.append(WeightedEdge(tail: 2, head: 7, weight: 0.34))
    edges.append(WeightedEdge(tail: 6, head: 2, weight: -1.20))
    edges.append(WeightedEdge(tail: 3, head: 6, weight: 0.52))
    edges.append(WeightedEdge(tail: 6, head: 0, weight: -1.40))
    edges.append(WeightedEdge(tail: 6, head: 4, weight: -1.25))
    
    return AdjacencyList(kind: .directed, edges: edges)
}

func givenTinyEWDnc() -> AdjacencyList<WeightedEdge<Double>> {
    // Set the graph to be a digraph with a negative cycle.
    // Same from Algorithms 4th edition p.678 tinyEWDnc.txt
    var edges = Array<WeightedEdge<Double>>()
    
    edges.append(WeightedEdge(tail: 4, head: 5, weight: 0.35))
    edges.append(WeightedEdge(tail: 5, head: 4, weight: -0.66))
    edges.append(WeightedEdge(tail: 4, head: 7, weight: 0.37))
    edges.append(WeightedEdge(tail: 5, head: 7, weight: 0.28))
    edges.append(WeightedEdge(tail: 7, head: 5, weight: 0.28))
    edges.append(WeightedEdge(tail: 5, head: 1, weight: 0.32))
    edges.append(WeightedEdge(tail: 0, head: 4, weight: 0.38))
    edges.append(WeightedEdge(tail: 0, head: 2, weight: 0.26))
    edges.append(WeightedEdge(tail: 7, head: 3, weight: 0.39))
    edges.append(WeightedEdge(tail: 1, head: 3, weight: 0.29))
    edges.append(WeightedEdge(tail: 2, head: 7, weight: 0.34))
    edges.append(WeightedEdge(tail: 6, head: 2, weight: 0.40))
    edges.append(WeightedEdge(tail: 3, head: 6, weight: 0.52))
    edges.append(WeightedEdge(tail: 6, head: 0, weight: 0.58))
    edges.append(WeightedEdge(tail: 6, head: 4, weight: 0.93))
    
    return AdjacencyList(kind: .directed, edges: edges)
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
        XCTFail("Different kind values lhs: \(lhs.kind), rhs: \(rhs.kind) - \(message)", file: file, line: line)
        
        return
    }
    
    guard
        lhs.vertexCount == rhs.vertexCount
    else {
        XCTFail("Different vertexCount values lhs: \(lhs.vertexCount), rhs: \(rhs.vertexCount) - \(message)", file: file, line: line)
        
        return
    }
    
    guard
        lhs.edgeCount == rhs.edgeCount
    else {
        XCTFail("Different edgeCount values lhs: \(lhs.edgeCount), rhs: \(rhs.edgeCount) - \(message)", file: file, line: line)
        
        return
    }
    
    for vertex in 0..<lhs.vertexCount {
        let lhsEdges = lhs.adjacencies(vertex: vertex)
        var rhsEdges = rhs.adjacencies(vertex: vertex)
        guard
            lhsEdges.count == rhsEdges.count
        else {
            XCTFail("Different adjacencies at vertex: \(vertex) - \(message)", file: file, line: line)
            
            return
        }
        
        for edge in lhsEdges {
            guard
                let idx = rhsEdges.firstIndex(of: edge)
            else {
                XCTFail("Different adjacencies at vertex: \(vertex) - \(message)", file: file, line: line)
                
                return
            }
            
            rhsEdges.remove(at: idx)
        }
        
        guard rhsEdges.isEmpty else {
            
            XCTFail("Different adjacencies at vertex: \(vertex) - \(message)", file: file, line: line)
            
            return
        }
    }
}

func assertContainsSameUndirectedWeightedEdges<W: WeightedGraphEdge>(lhs: Array<W>?, rhs: Array<W>?, file: StaticString = #file, line: UInt = #line) {
    switch (lhs, rhs) {
    case (nil, nil):
        return
    case (nil, .some):
        fallthrough
    case (.some, nil):
        XCTFail("\(lhs!) is not equal to nil", file: file, line: line)
        return
    case (.some(let l), .some(let r)):
        guard
            l.count == r.count
        else {
            XCTFail("\(l) is not equal to \(r)", file: file, line: line)
            return
        }
        
        let lSorted = l.sorted(by: { $0.weight < $1.weight })
        let rSorted = r.sorted(by: { $0.weight < $1.weight })
        for (lEdge, rEdge) in zip(lSorted, rSorted) {
            guard
                lEdge <=~=> rEdge
            else {
                XCTFail("\(l) is not equal to \(r)", file: file, line: line)
                return
            }
        }
    }
}
