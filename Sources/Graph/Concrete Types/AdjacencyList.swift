//
//  AdjacencyList.swift
//  Graph
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

/// A mutable graph, generic over the `Edge` type and adopting as storage for its edges an adjacency list.
public struct AdjacencyList<Edge: GraphEdge> {
    public let kind: GraphConnections
    
    public let vertexCount: Int
    
    public fileprivate(set) var edgeCount: Int = 0
    
    fileprivate(set) var _adjacencies: [[Edge]]
    
    public init(kind: GraphConnections, vertexCount: Int) {
        precondition(vertexCount >= 0, "vertexCount must not be negative.")
        
        self.kind = kind
        self.vertexCount = vertexCount
        self._adjacencies = Array(repeating: [], count: vertexCount)
    }
    
}

// MARK: - Graph conformance
extension AdjacencyList: Graph {
    public init(kind: GraphConnections, edges: [Edge]) {
        self.kind = kind
        guard !edges.isEmpty else {
            self._adjacencies = []
            self.vertexCount = 0
            
            return
        }
        
        self._adjacencies = [[]]
        var maxVertex = 0
        for edge in edges {
            let v = edge.either
            let w = edge.other(v)
            precondition(v >= 0 && w >= 0, "Edge: \(edge) has one or both vertcies values negative.")
            
            let diff = Swift.max(maxVertex, Swift.max(v, w)) - maxVertex
            if diff > 0 {
                _adjacencies.append(contentsOf: Array(repeating: [], count: diff))
                maxVertex += diff
            }
            _adjacencies[v].append(edge)
            if kind == .undirected {
                _adjacencies[w].append(edge.reversed())
            }
        }
        
        self.vertexCount = maxVertex + 1
        self.edgeCount = edges.count
    }
    
    public func adjacencies(vertex: Int) -> [Edge] {
        _adjacencies[vertex]
    }
    
    public func reversed() -> AdjacencyList<Edge> {
        guard kind == .directed else { return self }
        
        var revGraph = self
        revGraph._invertAdjacencies()
        
        return revGraph
    }
    
}

// MARK: - MutableGraph conformance
extension AdjacencyList: MutableGraph {
    public mutating func add(edge: Edge) {
        let v = edge.either
        let w = edge.other(v)
        guard
            0..<vertexCount ~= v,
            0..<vertexCount ~= w
        else { preconditionFailure("Edge: \(edge) is out of bounds.") }
        
        _adjacencies[v].append(edge)
        if kind == .undirected {
            _adjacencies[w].append(edge.reversed())
        }
        edgeCount += 1
    }
    
    public mutating func remove(edge: Edge) -> Bool {
        let v = edge.either
        let w = edge.other(v)
        guard
            0..<vertexCount ~= v,
            0..<vertexCount ~= w
        else { preconditionFailure("Edge: \(edge) is out of bounds.") }
        
        guard
            let vIndex = _adjacencies[v].firstIndex(of: edge)
        else { return false }
        
        defer {
            edgeCount -= 1
            _adjacencies[v].remove(at: vIndex)
            if kind == .undirected {
                let wIndex = _adjacencies[w].firstIndex(of: edge.reversed())
                assert(wIndex != nil, "Not found reveresed edge in \(w) adjacencies.")
                _adjacencies[w].remove(at: wIndex!)
            }
        }
        
        return true
    }
    
    public mutating func removeAllEdges() {
        _adjacencies = Array(repeating: [], count: vertexCount)
        edgeCount = 0
    }
    
    public mutating func reverse() {
        guard
            kind == .directed
        else { return }
        
        self._invertAdjacencies()
    }
    
}

// MARK: - Codable conformance
extension AdjacencyList: Codable where Edge: Codable {
    @frozen
    enum CodingKeys: String, CodingKey {
        case kind
        case vertexCount
        case edges
        
    }
    
    /// Error thrown by `AdjacencyList` when validating decoded data.
    public enum Error: Swift.Error {
        /// Thrown when decoded data for an edge contains either or both vertices
        /// not in range `0..<vertexCount`.
        case decodedEdgeOutBounds
        
        /// Thrown when decoded data for `vertexCount` is a negative value.
        case decodedVertexCountNegative
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let _kind = try container.decode(GraphConnections.self, forKey: .kind)
        let _vertexCount = try container.decode(Int.self, forKey: .vertexCount)
        guard _vertexCount >= 0 else { throw Error.decodedVertexCountNegative }
        
        let _edges = try container.decode(Array<Edge>.self, forKey: .edges)
        let rangeOfEdgeVertex = 0..<_vertexCount
        var adjacencies = Array<Array<Edge>>(repeating: [], count: _vertexCount)
        try _edges.forEach({ edge in
            let vertex = edge.either
            let other = edge.other(vertex)
            guard
                rangeOfEdgeVertex ~= vertex,
                rangeOfEdgeVertex ~= other
            else { throw Error.decodedEdgeOutBounds }
            
            adjacencies[vertex].append(edge)
            if _kind == .undirected {
                adjacencies[other].append(edge.reversed())
            }
        })
        
        self.init(kind: _kind, adjacencyList: adjacencies, edgeCount: _edges.count)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(kind, forKey: .kind)
        try container.encode(vertexCount, forKey: .vertexCount)
        var addSelfLoop = true
        let edges = kind == .directed ? _adjacencies.flatMap { $0 } : (0..<vertexCount).reduce([], { running, vertex in
            running + _adjacencies[vertex].filter({ edge in
                guard
                    !edge.isSelfLoop
                else {
                    defer {
                        addSelfLoop = !addSelfLoop
                    }
                    
                    return addSelfLoop
                }
                
                return edge.other(vertex) > vertex
            })
        })
        
        try container.encode(edges, forKey: .edges)
    }
    
}

// MARK: - Private helepers
extension AdjacencyList {
    fileprivate init(kind: GraphConnections, adjacencyList: Array<Array<Edge>>, edgeCount: Int) {
        self.kind = kind
        self.vertexCount = adjacencyList.count
        self._adjacencies = adjacencyList
        self.edgeCount = edgeCount
    }
    
    fileprivate mutating func _invertAdjacencies() {
        var inverted = Array<Array<Edge>>(repeating: [], count: vertexCount)
        while let edges = _adjacencies.popLast() {
            edges.forEach({ edge in
                let reversedEdge = edge.reversed()
                inverted[reversedEdge.either].append(reversedEdge)
            })
        }
        _adjacencies = inverted
    }
    
}
