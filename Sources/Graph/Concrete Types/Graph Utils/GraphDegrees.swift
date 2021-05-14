//
//  GraphDegrees.swift
//  Graph
//
//  Created by Valeriano Della Longa on 2021/05/01.
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

/// An utility to query a graph for some features as the outdegree and indegree of a vertex.
///
/// Since a graph can contain a huge number of vertices and edges, this utility is a stand-alone class type which
/// gets initialized with the graph to query.
/// Results for queries are calculated lazily the first time a query is made.
/// Note that results are valid for the graph state used at initialization time, thus a new instance must be
/// created to query a mutated graph instance.
public final class GraphDegrees<G: Graph> {
    /// The graph to query.
    public let graph: G
    
    /// An array containing all the queried graph's edges.
    ///
    /// The `kind` property value of the queried graph is taken into account, thus duplicate edge values
    /// when the queried graph is an **undirected graph** are not returned.
    /// That is, the lenght of this array will match the `edgeCount` property value of the queried graph,
    /// and this value effectively represents all the adjacencies in the queried graph.
    /// - Complexity:   Amortized O(1). It will take O(*V* + *E*) complexity to build this result when
    ///                 queried for the first time, where *V* is the count of vertices of the queried graph,
    ///                 and *E* is the number of edges in the queried graph.
    public private(set) lazy var allEdges: [G.Edge] = {
        switch graph.kind {
        case .directed:
            return (0..<graph.vertexCount).flatMap({ graph.adjacencies(vertex: $0) })
        case .undirected:
            var addSelfLoop = true
            
            return (0..<graph.vertexCount).reduce([], { edges, currentVertex in
                edges + graph.adjacencies(vertex: currentVertex).filter({ edge in
                    guard
                        !edge.isSelfLoop
                    else {
                        defer {
                            addSelfLoop = !addSelfLoop
                        }
                        
                        return addSelfLoop
                    }
                    
                    return edge.other(currentVertex) > currentVertex
                })
            })
        }
    }()
    
    /// The maximum outdegree of a vertex in the queried graph.
    ///
    /// - Complexity:   Amortized O(1). It will take O(*V* + *E*) complexity to build this result when
    ///                 queried for the first time, where *V* is the count of vertices of the queried graph,
    ///                 and *E* is the number of edges in the queried graph.
    public private(set) lazy var maxOutdegree: Int = {
        (0..<graph.vertexCount)
            .map({ graph.adjacencies(vertex: $0).count
            })
            .max() ?? 0
    }()
    
    /// A Double value representing the average outdegree value of the queried graph's vertices.
    ///
    /// - Complexity: O(1).
    public private(set) lazy var averageOutdegree: Double = {
        guard
            graph.vertexCount > 0
        else { return 0 }
        
        return Double(graph.edgeCount) * (graph.kind == .directed ? 1.0 : 2.0) / Double(graph.vertexCount)
    }()
    
    /// The number of edges in the queried graph expressing a loop over the same vertex.
    ///
    /// - Complexity:   Amortized O(1). It will take O(*V* + *E*) complexity to build this result when
    ///                 queried for the first time, where *V* is the count of vertices of the queried graph,
    ///                 and *E* is the number of edges in the queried graph.
    public private(set) lazy var countOfSelfLoops: Int = {
        allEdges.filter({ $0.isSelfLoop }).count
    }()
    
    private var _memoizedIndegrees = NSCache<NSNumber, NSNumber>()
    
    /// Returns a new instance of `GrapDegree` initalized with the given graph.
    ///
    /// - Parameter graph: Some `Graph` instance.
    /// - Returns: A new `GraphDegree` instance.
    /// - Complexity: O(1).
    public init(graph: G) {
        self.graph = graph
    }
    
    /// Returns the number of edges in the queried graph going outward from the given vertex.
    ///
    /// - Parameter vertex: The vertex for which calculate the *outdegree* value.
    ///                     **Must be in graph**.
    /// - Returns:  An `Int` value representing the number of edges in the queried graph
    ///             going outward from the given vertex.
    /// - Precondition: `vertex` parameter must be included in `graph.vertices`.
    /// - Complexity: O(1).
    func outdegree(of vertex: Int) -> Int {
        precondition(0..<graph.vertexCount ~= vertex, "Vertex: \(vertex) is not in graph.")
        
        return graph.adjacencies(vertex: vertex).count
    }
    
    /// Returns the number of edges in the queried graph going inward to the given vertex.
    ///
    /// - Parameter vertex: The vertex for which calculate the *indegree* value.
    /// - Returns:  An `Int` value representing the number of edges in the queried graph
    ///             going inward to the given vertex.
    /// - Precondition: `vertex` parameter must be included in `graph.vertices`.
    /// - Complexity:   O(*V* + *E*), where *V* is the count of vertices of the queried graph,
    ///                 and *E* is the number of edges in the queried graph.
    func indegree(of vertex: Int) -> Int {
        precondition(0..<graph.vertexCount ~= vertex, "Vertex: \(vertex) is not in graph.")
        
        let key = vertex as NSNumber
        guard let result = _memoizedIndegrees.object(forKey: key) else {
            let result = (0..<graph.vertexCount)
                .reduce(0, { result, source in
                    result + graph.adjacencies(vertex: source)
                        .filter({ edge in
                            vertex == edge.other(source)
                        }).count
                })
            defer {
                _memoizedIndegrees.setObject(result as NSNumber, forKey: key)
            }
            
            return result
        }
        
        return result.intValue
    }
    
}
