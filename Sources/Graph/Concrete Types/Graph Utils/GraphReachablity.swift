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

/// An utility to query a graph for reachability from a given set of source vertices.
///
/// Since a graph can contain a huge number of vertices and edges, this utility is a stand-alone class type which
/// gets initialized with the graph to query.
/// Results for queries are calculated lazily the first time a query is made.
/// Note that results are valid for the graph state used at initialization time, thus a new instance must be
/// created to query a mutated graph instance.
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
    public func isReachableFromSources(_ destination: Int) -> Bool {
        precondition(0..<graph.vertexCount ~= destination, "Vertex: \(destination) is not in graph.")
        
        return visited.contains(destination)
    }
    
}
