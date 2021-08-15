//
//  GraphAcyclicSP.swift
//  Graph
//
//  Created by Valeriano Della Longa on 2021/08/13.
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

/// A utility to query a weighted graph for the shortest paths from a source vertex to other vertices.
///
/// Since a graph can contain a huge number of vertices and edges and the algorithm for finding shortest paths leverages on
/// DAGs, this utility is a stand-alone class type which gets initialized directly from the GraphCycle utility.
/// Results for queries are calculated lazily the first time a query is made.
/// Note that results are valid for the graph state used at initialization time, thus a new instance must be
/// created to query a mutated graph instance.
/// - Note: This utility adopts an algorithm leveraging on the topological sort of a directed graph;
///         therefore complexity of first query should be in the magnitude of O(?).
/// - Important:    `GraphAcyclicSP` new instances can only be instanciated and obtained
///                 by querying a `GraphCycle` utility instance via its `shortestsPaths(from:)`
///                 method. Such instance method only returns a valid `GraphAcyclicSP` instance
///                 if its queried graph is an edge weighted directed acyclic graph.
public final class GraphAcyclicSP<G: Graph> where G.Edge: WeightedGraphEdge {
    /// The graph to query.
    public let graph: G
    
    /// The source vertex to query.
    public let source: Int
    
    fileprivate let _topologicalSort: Array<Int>
    
    fileprivate lazy var _edgeTo: Array<G.Edge?> = {
        let (edgeTo, weightTo) = _buildShortestPaths()
        defer {
            self._weightTo = weightTo
        }
        
        return edgeTo
    }()
    
    fileprivate lazy var _weightTo: Array<G.Edge.Weight?> = {
        let (edgeTo, weightTo) = _buildShortestPaths()
        defer {
            self._edgeTo = edgeTo
        }
        
        return weightTo
    }()
    
    fileprivate let _memoizedSP = NSCache<NSNumber, NSArray>()
    
    internal init?(_ cycle: GraphCycle<G>, source: Int) {
        guard
            let topologicalSort = cycle.topologicalSort
        else { return nil }
        
        self.graph = cycle.graph
        
        self.source = source
        
        self._topologicalSort = topologicalSort
    }
    
}

extension GraphAcyclicSP {
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

extension GraphAcyclicSP {
    fileprivate func _buildShortestPaths() -> (edgeTo: Array<G.Edge?>, weightTo: Array<G.Edge.Weight?>) {
        var edgeTo = Array<G.Edge?>(repeating: nil, count: graph.vertexCount)
        var weightTo = Array<G.Edge.Weight?>(repeating: nil, count: graph.vertexCount)
        weightTo[source] = .zero
        guard
            graph.edgeCount > 0
        else {
            return (edgeTo, weightTo)
        }
        
        let relax: (Int) -> Void = { [graph] vertex in
            for edge in graph.adjacencies(vertex: vertex) {
                let other = edge.other(vertex)
                if let vertexW = weightTo[vertex] {
                    if weightTo[other] == nil || weightTo[other]! > vertexW + edge.weight {
                        weightTo[other] = vertexW + edge.weight
                        edgeTo[other] = edge
                    }
                }
            }
        }
        for v in _topologicalSort {
            relax(v)
        }
        
        return (edgeTo, weightTo)
    }
    
}

extension GraphCycle where G.Edge: WeightedGraphEdge {
    /// Returns the shortest paths utility for the queried directed weighted graph when such graph is also acyclic,
    /// otherwise nil.
    /// That is for an edge weighted direct acyclic graph the utility for shortest paths can be build.
    ///
    /// - Parameter source: The source vertex for quering shortest paths.
    ///                     **Must be included in the queried  graph.**
    /// - Returns:  A `GraphAcyclicSP` utilty instance initialized to be queried for shortest paths from the given
    ///             `source` vertex to other vertices of the queried `graph`, nil in case the `graph` is not
    ///             an acyclic edge weighted directed graph.
    /// - Complexity:   Amortized O(1). It will take O(*V* + *E*) complexity when queried for the first time,
    ///                 where *V* is the count of vertices and *E* is count of edges of the queried graph.
    public func shortestsPaths(from source: Int) -> GraphAcyclicSP<G>? {
        precondition((0..<graph.vertexCount) ~= source, "source vertex must be in queried graph.")
        
        return GraphAcyclicSP(self, source: source)
    }
    
}
