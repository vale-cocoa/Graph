//
//  GraphSP.swift
//  Graph
//
//  Created by Valeriano Della Longa on 2021/08/09.
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

/// A utility to query a weighted graph for the shortest paths from a source vertex to other vertices.
///
/// Since a graph can contain a huge number of vertices and edges, this utility is a stand-alone class type which
/// gets initialized with the weighted graph to query and the source vertex.
/// Results for queries are calculated lazily the first time a query is made.
/// Note that results are valid for the graph state used at initialization time, thus a new instance must be
/// created to query a mutated graph instance
/// - Note: This utility adopts the Bellman-Ford algorithm; implementation is queue based,
///         therefore overall complexity will be most likely O(*E* + *V*) for the first query.
public final class GraphSP<G: Graph> where G.Edge: WeightedGraphEdge {
    /// The graph to query.
    public let graph: G
    
    /// The source vertex to query.
    public let source: Int
    
    fileprivate lazy var _edgeTo: Array<G.Edge?> = {
        let (edgeTo, weightTo, _negativeCycle) = _buildShortestPaths()
        defer {
            self._weightTo = weightTo
            self.negativeCycle = _negativeCycle
        }
        
        return edgeTo
    }()
    
    fileprivate lazy var _weightTo: Array<G.Edge.Weight?> = {
        let (edgeTo, weightTo, _negativeCycle) = _buildShortestPaths()
        defer {
            self._edgeTo = edgeTo
            self.negativeCycle = _negativeCycle
        }
        
        return weightTo
    }()
    
    /// An array of vertices in the queried graph which represents a negative cycle found while attempting to build
    /// shortest paths. Empty when the queried graph doesn't contain any negative cycle.
    ///
    /// - Complexity:   O(*E* *V*) where *E* is the count of edges and *V* is the count of vertices
    ///                 in the queried graph when queried for the first time, then O(1) for subsequent queries.
    public fileprivate(set) lazy var negativeCycle: Array<Int> = {
        let (edgeTo, weightTo, _negativeCyle) = _buildShortestPaths()
        defer {
            self._edgeTo = edgeTo
            self._weightTo = weightTo
        }
        
        return _negativeCyle
    }()
    
    fileprivate let _memoizedSP = NSCache<NSNumber, NSArray>()
    
    /// Returns a new `GraphSP` instance initialized to the given graph and the given source values.
    ///
    /// - Parameter graph: Some `Graph` instance, **must have vertexCount value grater than 0**.
    /// - Parameter source: A vertex, **must be included in given graph**.
    /// - Returns: A new `GraphSP` instance intialized to the specified parameters.
    /// - Complexity: O(1)
    public init(graph: G, source: Int) {
        precondition(0..<graph.vertexCount ~= source, "source must be a vertex in graph.")
        
        self.graph = graph
        self.source = source
    }
    
}

extension GraphSP {
    /// Returns the total weight to reach given destination vartex in queried graph from source vertex,
    /// `nil` when such vertex is not reachable from source vertex of a shortest path couldn't be calculated.
    ///
    /// - Parameter vertex: The destination vertex. **Must be included in queried graph**.
    /// - Returns:  The total weight of the shortest path from the queried source vertex to the given
    ///             destination vertex if such path exists in queried graph otherwise `nil`.
    /// - Complexity:   O(*E* *V*) where *E* is the count of edges and *V* is the count of vertices
    ///                 in the queried graph when queried for the first time, then O(1) for subsequent queries.
    public func weight(to vertex: Int) -> G.Edge.Weight? {
        precondition(0..<graph.vertexCount ~= vertex, "Destination vertex must be in graph.")
        
        return _weightTo.withUnsafeBufferPointer({ $0[vertex] })
    }
    
    /// Returns `true` if there is a path in queried graph connecting the queried source vertex to
    /// the given destination vertex; otherwise `false`.
    ///
    /// - Parameter vertex: The destination vertex. **Must be included in queried graph**.
    /// - Returns:  A boolean value: `true` if there is a path connecting the queried source
    ///             and the given destination vertices in the queried graph, otherwise `false`.
    /// - Complexity:   O(*E* *V*) where *E* is the count of edges and *V* is the count of vertices
    ///                 in the queried graph when queried for the first time, then O(1) for subsequent queries.
    public func hasPath(to vertex: Int) -> Bool {
        precondition(0..<graph.vertexCount ~= vertex, "Destination vertex must be in graph.")
        
        return _weightTo.withUnsafeBufferPointer({ $0[vertex] }) != nil
    }
    
    /// Returns a sequence of edges representing the shortest path in the queried graph
    /// going from the queried source to the given destination verticies.
    /// Such sequence will be empty if there is not such path.
    ///
    /// - Parameter vertex: The destination vertex. **Must be included in queried graph**.
    /// - Returns:  A sequence of edges representing the shortest path in the queried graph
    ///             going from the queried source to the given destination verticies.
    ///             Such sequence will be empty if there is not such path.
    /// - Complexity:   O(*E* *V*) where *E* is the count of edges and *V* is the count of vertices
    ///                 in the queried graph when queried for the first time,
    ///                 then amortized O(1) for subsequent queries.
    public func path(to vertex: Int) -> AnySequence<G.Edge> {
        guard
            vertex != source,
            hasPath(to: vertex)
        else { return AnySequence(EmptyCollection()) }
        
        let base: Array<G.Edge>!
        if let cached = _memoizedSP.object(forKey: vertex as NSNumber) as? Array<G.Edge> {
            
            base = cached
        } else {
            var reversedPath = Array<G.Edge>()
            var from = vertex
            while let edge = _edgeTo.withUnsafeBufferPointer({ $0[from] }) {
                reversedPath.append(edge)
                from = edge.other(from)
            }
            defer {
                _memoizedSP.setObject(reversedPath as NSArray, forKey: vertex as NSNumber)
            }
            
            base = reversedPath
        }
        
        return AnySequence(base.lazy.reversed())
    }
    
}

extension GraphSP {
    fileprivate func _buildShortestPaths() -> (edgeTo: Array<G.Edge?>, weightTo: Array<G.Edge.Weight?>, negativeCycle: Array<Int>) {
        var edgeTo = Array<G.Edge?>(repeating: nil, count: graph.vertexCount)
        var weightTo = Array<G.Edge.Weight?>(repeating: nil, count: graph.vertexCount)
        weightTo[source] = .zero
        var negativeCycle: Array<Int> = []
        guard
            graph.edgeCount > 0
        else {
            return (edgeTo, weightTo, negativeCycle)
        }
        
        var onQueue: Set<Int> = []
        var cost = 0
        var queue = Deque<Int>()
        let relax: (Int) -> Void = { [graph] vertex in
            for edge in graph.adjacencies(vertex: vertex) {
                let other = edge.other(vertex)
                if let vertexW = weightTo[vertex] {
                    if weightTo[other] == nil || weightTo[other]! > vertexW + edge.weight {
                        weightTo[other] = vertexW + edge.weight
                        edgeTo[other] = edge
                        if onQueue.insert(other).inserted == true {
                            queue.enqueue(other)
                        }
                    }
                }
                cost += 1
                if cost % graph.vertexCount == 0 {
                    let edgesInTree = edgeTo.compactMap({ $0 })
                    let candidateCycle = AdjacencyList(kind: .directed, edges: edgesInTree)
                    negativeCycle = GraphCycle(graph: candidateCycle).cycle
                }
            }
        }
        queue.enqueue(source)
        onQueue.insert(source)
        while
            let v = queue.dequeue(),
              negativeCycle.isEmpty
        {
            onQueue.remove(v)
            relax(v)
        }
        
        return (edgeTo, weightTo, negativeCycle)
    }
    
}

