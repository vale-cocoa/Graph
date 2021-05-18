//
//  GraphTransitiveClosure.swift
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

import Foundation

/// A utility to query a graph for its transitive closure.
///
/// Since a graph can contain a huge number of vertices and edges, this utility is a stand-alone class type which
/// gets initialized with the graph to query.
/// Results for queries are calculated lazily the first time a query is made.
/// Note that results are valid for the graph state used at initialization time, thus a new instance of this utility
/// must be created to query a mutated graph.
/// - Note: Transitive closure is a term meant to be related to directed graphs,
///         this utility though queries graphs with both type of vertex connetions, directed and undirected,
///         stressing the main functionality of finding reachability between two vertices in the queried graph.
public final class GraphTransitiveClosure<G: Graph> {
    /// The graph to query.
    public let graph: G
    
    private let _memoizedVisited = NSCache<NSNumber, NSSet>()
    
    private lazy var _connectedComponents: GraphStronglyConnectedComponents<G> = {
        GraphStronglyConnectedComponents(graph: graph)
    }()
    
    /// Returns a new instance of `GraphTransitiveClosure` initalized with the given graph.
    ///
    /// - Parameter graph: Some `Graph` instance.
    /// - Returns: A new `GraphTransitiveClosure` instance to query the given graph.
    /// - Complexity: O(1).
    public init(graph: G) {
        self.graph = graph
    }
    
    /// Given two vertices, returns a boolean value, `true` when the second vertex is reachable from the first one
    /// in the queried graph; otherwise false.
    ///
    /// - Parameter source: A vertex, **must be in the queried graph**.
    /// - Parameter destination: A vertex, **must be in the queried graph**.
    /// - Returns:  A boolean value, `true` when the vertex specified as `destination` parameter
    ///             is reachable from the vertex specified as `source` parameter; otherwise `false`.
    /// - Complexity:   For quereried graphs with `kind == .undirected` amortized O(1).
    ///                 It will take O(*V* + *E*) complexity to build this result when
    ///                 queried for the first time, where *V* is the count of vertices of the queried graph,
    ///                 and *E* is the number of edges in the queried graph.
    ///                 For the queried graphs with `kind == .directed`
    ///                 O(*V* + *E*) complexity, where *V* is the count of vertices
    ///                 of the queried graph and *E* is the count of edges in the queried graph.
    ///                 In practice it would be amortized O(1) complexity for every
    ///                 subsequent query made for the same source vertex, since this utility
    ///                 memozises in its cache the reachability map from such vertex
    ///                 after it was built when queried for the first time.
    public func reachability(from source: Int, to destination: Int) -> Bool {
        precondition(0..<graph.vertexCount ~= source, "Vertex: \(source) is not in graph.")
        precondition(0..<graph.vertexCount ~= destination, "Vertex: \(destination) is not in graph.")
        
        guard
            graph.kind == .directed
        else {
            
            return _connectedComponents.areStronglyConnected(source, destination)
        }
        
        if let cached = _memoizedVisited.object(forKey: source as NSNumber) {
            
            return cached.contains(destination)
        }
        
        let visited = graph.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: source, { _ in})
        defer {
            _memoizedVisited.setObject(visited as NSSet, forKey: source as NSNumber)
        }
        
        return visited.contains(destination)
    }
    
}
