//
//  GraphPaths.swift
//  Graph
//
//  Created by Valeriano Della Longa on 2021/04/15.
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

/// An utility to query a graph for paths from a given source vertex.
///
/// Since a graph can contain a huge number of vertices and edges, this utility is a stand-alone class type which
/// gets initialized with the graph to query.
/// Results for queries are calculated lazily the first time a query is made.
/// Note that results are valid for the graph state used at initialization time, thus a new instance must be
/// created to query a mutated graph instance.
public final class GraphPaths< G: Graph> {
    /// The graph to query.
    public let graph: G
    
    /// The source vertex to query.
    public let source: Int
    
    /// The type of graph traversal used to build paths from queried source vertex.
    public let traversal: GraphTraversal
    
    private lazy var _visited: Set<Int> = {
        let data = _buildData()
        defer {
            _edgeTo = data.edgeTo
        }
        
        return data.visited
    }()
    
    private lazy var _edgeTo: Array<Int?> = {
        let data = _buildData()
        defer {
            _visited = data.visited
        }
        
        return data.edgeTo
    }()
    
    private let _memoizedPaths = NSCache<NSNumber, NSArray>()
    
    /// Returns a new `GraphPaths` instance initialized to the given graph, the given source vertex and the given
    /// graph traversal values.
    ///
    /// - Parameter graph: Some `Graph` instance, **must have vertexCount value grater than 0**.
    /// - Parameter source: A vertex, **must be include in given graph**.
    /// - Parameter traversal:  A `GraphTraversal` value, paths from given `source` vertex will
    ///                         be built traversing the given `graph` adopting the specified value for
    ///                         this parameter.
    /// - Returns: A new `GraphPaths` instance intialized to the specified parameters.
    /// - Complexity: O(1)
    public init(graph: G, source: Int, buildPathsAdopting traversal: GraphTraversal) {
        precondition(0..<graph.vertexCount ~= source, "source must be a vertex in graph.")
        
        self.graph = graph
        self.source = source
        self.traversal = traversal
    }
    
    /// Returns a boolean value, true when there is a path in queried graph from the queried source to the given
    /// destination vertex.
    ///
    /// - Parameter destination: A vertex, **must be in queried graph**.
    /// - Returns:  A boolean value, true when a path exists in the queried graph from the queried
    ///             source to the given destination vertex. Note that this method returns true when
    ///             the given `destination` vertex value is the same of the queried `source` vertex.
    /// - Complexity:   Amortized O(1). It will take O(*V* + *E*) complexity to build this result when
    ///                 queried for the first time, where *V* is the count of vertices of the queried graph,
    ///                 and *E* is the number of edges in the queried graph.
    public func hasPath(to destination: Int) -> Bool {
        precondition(0..<graph.vertexCount ~= destination, "Vertex: \(destination) is not in graph.")
        
        return _visited.contains(destination)
    }
    
    /// Returns an array containing the vertices of the path in queried graph going from the queried source vertex
    /// to the given detination vertex. When such path doesn't exists, the returned array will be empty.
    ///
    /// - Parameter destination: A vertex, **must be in queried graph**.
    /// - Returns:  An array of vertices representing the path in the queried graph from
    ///             the queried source vertex to the given destination vertex.
    ///             Note that when the given `destination` vertex value is equal to
    ///             the queried `source` vertex value, this method will return an array containing
    ///             just such vertex.
    /// - Complexity:   Amortized O(*M*) where *M* is the number of edges in the queried graph to traverse
    ///                 (adopting the traversal strategy specified at initialization time) from the queried
    ///                 source vertex to the given destination vertex.
    ///                 It will take O(*E*) complexity to build this result when
    ///                 queried for the first time, where *E* is the number of edges in the queried graph.
    public func pathFromSource(to destination: Int) -> [Int] {
        guard hasPath(to: destination) else { return [] }
        
        if let cached = _memoizedPaths.object(forKey: destination as NSNumber) {
            
            return cached as! Array<Int>
        }
        
        var path: Array<Int> = []
        var current = destination
        while current != source {
            path.append(current)
            current = _edgeTo[current]!
        }
        path.append(current)
        path.reverse()
        defer {
            _memoizedPaths.setObject(path as NSArray, forKey: destination as NSNumber)
        }
        
        return path
    }
    
    private func _buildData() -> (visited: Set<Int>, edgeTo: Array<Int?>) {
        var edgeTo = Array<Int?>(repeating: nil, count: graph.vertexCount)
        var visited: Set<Int> = []
        let body: (Int, G.Edge) -> Void = { vertex, edge in
            let other = edge.other(vertex)
            edgeTo[other] = vertex
        }
        if traversal == .DeepFirstSearch {
            graph.recursiveDFS(reachableFrom: source, visited: &visited, body)
        } else {
            graph.iterativeBFS(reachableFrom: source, visited: &visited, body)
        }
        
        return (visited, edgeTo)
    }
    
}
