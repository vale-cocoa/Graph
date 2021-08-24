//
//  FlowNetwork.swift
//  Graph
//
//  Created by Valeriano Della Longa on 2021/08/17.
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

import Foundation
import Deque

/// A utility for building a flow network from two vertices in a weighted graph and query it for max-flow and min-cut.
///
/// Since a graph can contain a huge number of vertices and edges, this utility is a stand-alone class type which
/// gets initialized with the weighted graph to query and two of its vertices.
/// Results for queries are calculated lazily the first time one query is made between `maxFlow`, `inMinCut(_:)` or
/// `flowedAdjacencies(for:)`.
/// Note that results are valid for the graph state used at initialization time, thus a new instance must be
/// created to query a mutated graph instance.
/// The Ford-Fulkerson algorithm is adopted to create the max-flow and the min-cut in a flow network instance;
/// that is the worst case scenario complexity of creating the data at first query would be O(*E^2* *U*),
/// where *E* is the count of edges and *U* is the count of augmented paths in the flow network.
public final class FlowNetwork<G: Graph> where G.Edge: WeightedGraphEdge {
    /// The weighted graph instance used to create this `FlowNetwork` instance.
    public let graph: G
    
    /// The number of *flow edges* contained in this flow network instance. That is a *flow edge* is a
    /// weighted edge connecting two vertices in a flow network which also has associated the *flow* value of
    /// such connection.
    ///
    /// - Complexity: O(1)
    public let flowEdgeCount: Int
    
    /// A vertex in the graph, source of the flow network.
    public let s: Int
    
    /// A vertex in the graph, target of the flow network
    public let t: Int
    
    fileprivate let _flowedAdjacencies: Array<Array<FlowEdge>>
    
    /// The maximum flow in the flow network between vertex `s` and `t`.
    /// Returns `nil` value when `s` and `t` are the same vertex; returns `.zero` when
    /// `s` and `t` are not connected.
    ///
    /// - Complexity:   O(*E^2* *U*) the first time this value is queried —where *E* is the count of edges and
    ///                 *U* is the count of augmented paths in the flow network instance.
    ///                 Then O(1).
    public fileprivate(set) lazy var maxFlow: G.Edge.Weight? = {
        let (value, visited) = _fordFulkerson()
        defer {
            self._visited = visited
        }
        
        return value
    }()
    
    /// Returns an array containing the flow edges representing the min-cut of this flow network instance.
    ///
    /// - Complexity:   O(*E^2* *U*) the first time this value is queried —where *E* is the count of edges and
    ///                 *U* is the count of augmented paths in the flow network instance.
    ///                 Then O(1).
    public fileprivate(set) lazy var minCut: [FlowEdge] = {
        guard
            flowEdgeCount > 0,
            s != t
        else { return [] }
        
        return _visited
            .flatMap({ vertex in
                _flowedAdjacencies
                    .withUnsafeBufferPointer({ buffer in
                        buffer[vertex]
                            .filter({ flowEdge in
                                flowEdge.from == vertex && !_visited.contains(flowEdge.to)
                            })
                    })
            })
    }()
    
    fileprivate lazy var _visited: Set<Int> = {
        let (value, visited) = _fordFulkerson()
        defer {
            self.maxFlow = value
        }
        
        return visited
    }()
    
    /// Creates a new flow network instance with the given weighted graph, queriable for
    /// the max-flow value and min-cut between the given `s` and `t` vertices.
    /// Throws an `Error.negativeWeightedEdge` if the given weighted graph contains
    /// any edge with a negative weight value.
    ///
    /// - Parameter graph:  The weighted graph to use to build the flow network instance.
    /// - Parameter s:  A vertex to adopt as source in the flow network instance being created.
    ///                 **Must be in graph**.
    /// - Parameter t:  A vertex to adopt as target in the flow network instance being created.
    ///                 **Must be in graph**.
    /// - Returns: A new flow network instance deriving from the given weighted graph and vertices.
    /// - Throws:   A `.negativeWeightedEdge` error in case the given graph contains any
    ///             edge with a negative weight value.
    /// - Complexity:   O(*V* + *E*) where *V* is the count of vertices and *E* is the count of edges
    ///                 in the given weighted graph.
    public init(_ graph: G, s: Int, t: Int) throws {
        let vertices = 0..<graph.vertexCount
        precondition(vertices ~= s, "s vertex must be in graph")
        precondition(vertices ~= t, "t vertex must be in graph")
        self.graph = graph
        self.s = s
        self.t = t
        var adjs: Array<Array<FlowEdge>> = Array(repeating: [], count: graph.vertexCount)
        var feCount = 0
        try vertices.forEach({ vertex in
            try graph.adjacencies(vertex: vertex).forEach({ edge in
                let flowEdge: FlowEdge!
                let other: Int!
                switch graph.kind {
                case .undirected:
                    if edge.tail == vertex {
                        flowEdge = try FlowEdge(edge)
                        other = edge.head
                    } else {
                        flowEdge = try FlowEdge(edge.reversed())
                        other = edge.tail
                    }
                case .directed:
                    other = edge.other(vertex)
                    flowEdge = try FlowEdge(edge)
                }
                adjs.withUnsafeMutableBufferPointer({ buffer in
                    buffer[vertex].append(flowEdge)
                    buffer[other].append(flowEdge)
                })
                feCount += 2
            })
        })
        self._flowedAdjacencies = adjs
        self.flowEdgeCount = feCount
    }
    
}

// MARK: - FlowEdge
extension FlowNetwork {
    /// Error thrown by `FlowNetwork ` utility.
    public enum Error: Swift.Error {
        /// This error is thrown if the weighted graph used to build a flow network instance
        /// contains an edge with negative weight value. That is in a flow network edges must have
        /// positive *capacity*.
        case negativeWeightedEdge
        
    }
    
    /// A reference type representing a connection between two vertices in a flow network.
    public final class FlowEdge {
        fileprivate let edge: G.Edge
        
        /// The *flow* value of the connection between the two vertices in the flow network.
        /// That is the *flow* value is the amount of weight that this edge is set to to provide
        /// between the two vertices it connects in a flow network.
        public fileprivate(set) var flow: G.Edge.Weight = .zero
        
        internal init(_ edge: G.Edge) throws {
            guard edge.weight >= .zero else {
                throw Error.negativeWeightedEdge
            }
            
            self.edge = edge
        }
        
        /// The vertex from where the connection represented by this flow edge starts.
        public var from: Int { edge.tail }
        
        /// The vertex to where the connection represented by this flow edge ends.
        public var to: Int { edge.head }
        
        /// The *capacity* of this flow edge; that is *capacity* of a flow edge is the maximum amount of
        /// *weight* such edge can sustain as its *flow* in a flow network.
        public var capacity: G.Edge.Weight { edge.weight }
        
        /// Given a vertex in this flow edge as input, returns the other vertex of the represented connection.
        ///
        /// - Parameter vertex: A vertex; **must be one of the two vertices connected by this flow edge.**
        /// - Returns:  The other vertex of the connection represented by this flow edge; that is the vertex connected
        ///             to the one given as parameter.
        /// - Warning: A runtime error occurs in case the specified vertex is not one contained in this flow edge.
        public func other(_ vertex: Int) -> Int {
            edge.other(vertex)
        }
        
        /// Given a vertex in this flow edge as input, returns the *residual capacity* value of the connection to the
        /// other vertex connected by this flow edge.
        ///
        /// - Parameter vertex: A vertex; **must be one of the two vertices connected by this flow edge.**
        /// - Returns:  A *weight* value representing the *residual capacity* of this flow edge when the connection
        ///             shall be intended as going from the given vertex to the other vertex of the edge.
        /// - Warning: A runtime error occurs in case the specified vertex is not one contained in this flow edge.
        public func residualCapacity(to vertex: Int) -> G.Edge.Weight {
            switch vertex {
            case from:
                return flow
            case to:
                return edge.weight - flow
            default:
                preconditionFailure("vertex must be in this edge.")
            }
        }
        
        fileprivate func addResidualFlow(to vertex: Int, delta: G.Edge.Weight) {
            switch vertex {
            case from:
                flow -= delta
            case to:
                flow += delta
            default:
                preconditionFailure("vertex must be in this edge.")
            }
        }
        
    }
    
}

// MARK: - Public interface
extension FlowNetwork {
    /// The number of vertices contained in this flow network instance.
    ///
    /// - Complexity: O(1)
    public var vertexCount: Int { graph.vertexCount }
    
    /// Returns a boolean value, `true` when the given vertex is in the min-cut of the flow network instance;
    /// otherwise `false`.
    ///
    /// - Parameter vertex: A vertex; **must be in this flow network instance**.
    /// - Returns:  A boolean value, `true` when the given vertex is in the min-cut of the flow network instance;
    ///             otherwise `false`.
    /// - Complexity:   O(*E^2* *U*) the first time this value is queried —where *E* is the count of edges and
    ///                 *U* is the count of augmented paths in the flow network instance.
    ///                 Then O(1).
    public func inMinCut(_ vertex: Int) -> Bool {
        precondition(0..<graph.vertexCount ~= vertex, "vertex must be in graph.")
        
        return _visited.contains(vertex)
    }
    
    /// Returns an array containing the *flowed adjacencies* to the specified vertex in this flow network.
    /// That is a *flowed adjacency* to a vertex is a `FlowEdge`.
    ///
    /// - Parameter vertex: A vertex; **must be in this flow networkinstance**.
    /// - Returns:  An array of `FlowEdge` representing the *flowed adjacencies* of the specified `vertex`
    ///             in this flow network instance.
    /// - Complexity:   O(*E^2* *U*) the first time this value is queried —where *E* is the count of edges and
    ///                 *U* is the count of augmented paths in the flow network instance.
    ///                 Then O(1).
    /// - Note: `FlowEdge` instances eventually contained in the returned array have their `flow` value
    ///         already set to the calculated one for the max-flow between `s` and `t` vertices in this
    ///         flow network.
    public func flowedAdjacencies(for vertex: Int) -> Array<FlowEdge> {
        precondition(0..<graph.vertexCount ~= vertex, "vertex must be in graph.")
        let _ = maxFlow
        
        return _flowedAdjacencies.withUnsafeBufferPointer({ buffer in
            buffer[vertex]
        })
    }
    
}

// MARK: - Helpers
extension FlowNetwork {
    fileprivate func _fordFulkerson() -> (value: G.Edge.Weight?, visited: Set<Int>) {
        guard
            graph.edgeCount > 0
        else {
            if s != t {
                
                return (.zero, [s])
            } else {
                
                return (nil, [s])
            }
        }
        
        guard
            s != t
        else {
            return (nil, [s])
        }
        
        var visited: Set<Int> = []
        var flowEdgeTo = Array<FlowEdge?>(repeating: nil, count: graph.vertexCount)
        let hasAugmentingPath: () -> Bool = { [self] in
            visited.removeAll(keepingCapacity: true)
            flowEdgeTo = Array<FlowEdge?>(repeating: nil, count: graph.vertexCount)
            var queue = Deque<Int>()
            queue.enqueue(s)
            visited.insert(s)
            while let vertex = queue.dequeue() {
                for flowEdge in _flowedAdjacencies.withUnsafeBufferPointer({ $0[vertex] }) {
                    let other = flowEdge.other(vertex)
                    if
                        flowEdge.residualCapacity(to: other) > .zero && !visited.contains(other)
                    {
                        visited.insert(other)
                        flowEdgeTo[other] = flowEdge
                        queue.enqueue(other)
                    }
                }
            }
            
            return visited.contains(t)
        }
        var value: G.Edge.Weight? = .zero
        while hasAugmentingPath() == true {
            // guaranteed there is a path from s to t,
            // which has been saved in flowEdgeTo
            var bottleneck: G.Edge.Weight? = nil
            var v = t
            while v != s {
                let flowEdge = flowEdgeTo[v]!
                let residualCapacity = flowEdge.residualCapacity(to: v)
                bottleneck = bottleneck == nil ? residualCapacity : Swift.min(bottleneck!, residualCapacity)
                v = flowEdge.other(v)
            }
            v = t
            while v != s {
                let flowEdge = flowEdgeTo[v]!
                flowEdge.addResidualFlow(to: v, delta: bottleneck!)
                v = flowEdge.other(v)
            }
            if let bottleneck = bottleneck {
                guard
                    let oldValue = value
                else {
                    continue
                }
                value = oldValue + bottleneck
            } else {
                value = nil
            }
        }
        
        return (value, visited)
    }
    
}
