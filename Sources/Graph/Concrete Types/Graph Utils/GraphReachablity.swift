//
//  GraphReachablity.swift
//  Graph
//
//  Created by Valeriano Della Longa on 2021/05/08.
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

import Deque

/// A utility to query a graph for reachability from a given set of source vertices.
///
/// Since a graph can contain a huge number of vertices and edges, this utility is a stand-alone class type which
/// gets initialized with the graph to query and the source vertices.
/// Results for queries are calculated lazily the first time a query is made.
/// Note that results are valid for the graph state used at initialization time, thus a new instance of this utility
/// must be created to query a mutated graph.
public final class GraphReachability<G: Graph> {
    /// The graph to query.
    public let graph: G
    
    /// The source vertices to query.
    public let sources: Set<Int>
    
    private lazy var visited: Set<Int> = {
        var _visited = Set<Int>()
        for vertex in sources where !_visited.contains(vertex) {
            graph.recursiveDFS(reachableFrom: vertex, visited: &_visited, { _ in })
        }
        
        return _visited
    }()
    
    /// Returns a new `GraphReachability` instance initialized to the given graph and
    /// the given set of source vertices.
    ///
    /// - Parameter graph: Some `Graph` instance, **must have vertexCount value grater than 0**.
    /// - Parameter sources: A set of vertices, **must not be empty and every vertex contained in it must be in the given graph**.
    /// - Returns: A new `GraphReachability` instance intialized to the specified parameters.
    /// - Complexity: O(1)
    public init(graph: G, sources: Set<Int>) {
        precondition(!sources.isEmpty, "sources must contain at least one vertex of the graph.")
        precondition(sources.allSatisfy({
            0..<graph.vertexCount ~= $0
        }), "sources vertices must all be in graph.")
        
        self.graph = graph
        self.sources = sources
    }
    
    /// Returns a boolean value, true when the given destination vertex can be reached in the queried graph from one
    /// of the queried source vertices; false otherwise.
    ///
    /// - Parameter destination: A vertex, **Must be included in the queried graph**.
    /// - Returns:  A boolean value, true when the given destination vertex is reachable in
    ///             the queried graph from one of the queried source vertices. Note that when
    ///             the value specified as `destination` parameter is a vertex included in the
    ///             queried set of `sources` vertices, then this method will always return true.
    /// - Complexity:   Amortized O(1). It will take O(*V* + *E*) complexity to build this result when
    ///                 queried for the first time, where *V* is the count of vertices of the queried graph,
    ///                 and *E* is the number of edges in the queried graph.
    /// - Note: When the graph's `kind == .undirected` then it's guaranteed that also one of the vertices
    ///         included in the queried `sources` set is reachable from the given `destination` vertex.
    ///         On the other hand, when graph's `kind == .directed`, then it's
    ///         not guaranteed that queried `sources` set of vertices contains a vertex also reachable
    ///         from the given `destination` vertex, due to the *directed* connections of the graph.
    ///         In case there is a need to check if two vertices are *strongly connected* in a directed graph,
    ///         use the `GraphStronglyConnectedComponents` utility for such query.
    public func isReachableFromSources(_ destination: Int) -> Bool {
        precondition(0..<graph.vertexCount ~= destination, "Vertex: \(destination) is not in graph.")
        
        return visited.contains(destination)
    }
    
}

// MARK: - In-place reachability deafult implementations
extension Graph {
    /// Given two vertices, check if one is reachable form the other one in the graph. When given the same
    /// vertex as both, the `destination` parameter and the `source` parameter,
    /// this method returns `true`.
    /// That is a vertex in a graph is considered always reachable from itself even without
    /// the presence of an explicit self-loop edge in the graph for such vertex.
    ///
    /// - Parameter destination: A vertex, **must be included in graph**.
    /// - Parameter source: A vertex, **must be included in graph**.
    /// - Returns:  A boolean value, `true` if the given `destination` vertex is reachable in graph
    ///             from given `source` vertex; `false` otherwise.
    /// - Complexity: O(*V* + *E*) where *V* is the count of vertices and *E* is the count of edges in graph.
    /// - Note: When the graph's `kind == .undirected` then inverting the two given vertices
    ///         `destination` and `source` produces the same result.
    ///         On the other hand, when graph's `kind == .directed`, then it's
    ///         not guaranteed the given `source` vertex is also reachable
    ///         from the given `destination` vertex, due to the *directed* connections of the graph.
    ///         In case there is a need to check if the two vertices are *strongly connected* in a directed graph,
    ///         use the `GraphStronglyConnectedComponents` utility for such query.
    public func isReachable(_ destination: Int, from source: Int) -> Bool {
        precondition(0..<vertexCount ~= destination, "Vertex: \(destination) must be in graph.")
        precondition(0..<vertexCount ~= source, "Vertex: \(source) must be in graph.")
        guard destination != source else { return true }
        
        guard edgeCount > 0 else { return false }
        
        var visited: Set<Int> = [source]
        var queue: Deque<Int> = [source]
        while let vertex = queue.dequeue() {
            Inner: for edge in adjacencies(vertex: vertex) {
                let other = edge.other(vertex)
                guard other != destination else { return true }
                
                guard visited.insert(other).inserted else { continue Inner }
                
                queue.enqueue(other)
            }
        }
        
        return false
    }
    
    /// Given a non emtpy set of source vertices in graph, check if another vertex of the graph can be reached
    /// from the them. When the given `destination` vertex parameter is included in the given `sources`
    /// set of vertices parameter, then this method always returns `true`.
    /// That is a vertex in a graph is considered always reachable from itself even without
    /// the presence of an explicit self-loop edge in the graph for such vertex.
    ///
    /// - Parameter destination: A vertex, **must be included in graph**.
    /// - Parameter sources: A set of vertices, **must not be empty and all of its elements must be included in graph**.
    /// - Returns:  A boolean value, `true` if the given `destination` vertex is reachable in graph
    ///             from any of the vertices included in given `sources` parameter; `false` otherwise.
    /// - Complexity: O(*V* + *E*) where *V* is the count of vertices and *E* is the count of edges in graph.
    /// - Note: When the graph's `kind == .undirected` then it's guaranteed that also one of the vertices
    ///         included in the given `sources` set is reachable from the given `destination` vertex.
    ///         On the other hand, when graph's `kind == .directed`, then it's
    ///         not guaranteed the given `sources` set of vertices contains a vertex also reachable
    ///         from the given `destination` vertex, due to the *directed* connections of the graph.
    ///         In case there is a need to check if two vertices are *strongly connected* in a directed graph,
    ///         use the `GraphStronglyConnectedComponents` utility for such query.
    public func isReachable(_ destination: Int, from sources: Set<Int>) -> Bool {
        precondition(0..<vertexCount ~= destination, "Destination vertex: \(destination) must be in graph.")
        precondition(!sources.isEmpty, "Sources must contain at least one vertex.")
        precondition(sources.allSatisfy({ 0..<vertexCount ~= $0}), "Source vertices must all be in graph.")
        guard !sources.contains(destination) else { return true }
        
        guard edgeCount > 0 else { return false }
        
        var queue = Deque(sources)
        var visited = sources
        while let vertex = queue.dequeue() {
            Inner: for edge in adjacencies(vertex: vertex) {
                let other = edge.other(vertex)
                guard other != destination else { return true }
                
                guard visited.insert(other).inserted else { continue Inner }
                
                queue.enqueue(other)
            }
        }
        
        return false
    }
    
}
