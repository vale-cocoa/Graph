//
//  GraphStronglyConnectedComponents.swift
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

/// A utility to query a graph for its (strongly) connected components.
///
/// Since a graph can contain a huge number of vertices and edges, this utility is a stand-alone class type which
/// gets initialized with the graph to query.
/// Results for queries are calculated lazily the first time a query is made.
/// Note that results are valid for the graph state used at initialization time, thus a new instance of this utility
/// must be created to query a mutated graph.
/// - Note: For graphs of kind `.undirected` this utility builds connected components
///         adopting the depth first search traversal of the graph on every vertex.
///         On the other hand, for graphs of kind `.directed`, **strongly connected components**
///         are built by adopting the *Kosaraju-Sharir* algorithm.
public final class GraphStronglyConnectedComponents<G: Graph> {
    /// The graph to query.
    public let graph: G
    
    /// The number of (strongly) connected components found in the queried graph.
    ///
    /// - Complexity:   Amortized O(1). It will take O(*V* + *E*) complexity to build this result when
    ///                 queried for the first time, where *V* is the count of vertices of the queried graph,
    ///                 and *E* is the number of edges in the queried graph.
    public private(set) lazy var count: Int = {
        let data = _buildData()
        defer {
            _ids = data.ids
        }
        
        return data.count
    }()
    
    private lazy var _ids: Array<Int> = {
        let data = _buildData()
        defer {
            count = data.count
        }
        
        return data.ids
    }()
    
    private let _memoizedSCC = NSCache<NSNumber, NSArray>()
    
    /// Returns a new instance of `GraphStronglyConnectedComponents` initalized with the given graph.
    ///
    /// - Parameter graph: Some `Graph` instance.
    /// - Returns: A new `GraphStronglyConnectedComponents` instance to query the given graph.
    /// - Complexity: O(1).
    public init(graph: G) {
        self.graph = graph
    }
    
    /// Return true if the two given vertices are (strongly) connected in the queried graph, otherwise false.
    ///
    /// - Parameter v: A vertex, **must be in the queried graph**.
    /// - Parameter w: A vertex, **must be in the queried graph**.
    /// - Returns:  A boolean value, true if the two given vertices are (strongly) connected
    ///             in the queried graph, false otherwise.
    ///             When the two given vertices are the same one, then this method
    ///             always returns true.
    ///             That is, this utility considers every vertex of the queried graph to
    ///             be connected to itself regardless of the presence of a self loop edge.
    /// - Complexity:   Amortized O(1). It will take O(*V* + *E*) complexity to build this result when
    ///                 queried for the first time, where *V* is the count of vertices of the queried graph,
    ///                 and *E* is the number of edges in the queried graph.
    public func areStronglyConnected(_ v: Int, _ w: Int) -> Bool {
        precondition(0..<graph.vertexCount ~= v, "Vertex: \(v) is not in graph.")
        precondition(0..<graph.vertexCount ~= w, "Vertex: \(w) is not in graph.")
        
        return _ids[v] == _ids[w]
    }
    
    /// Returns an `Int` value in range `0..<count` representing the *id* of the (strongly) connected component
    /// where the given vertex lays in the queried graph.
    ///
    /// - Parameter vertex: A vertex, **must be in the queried graph**.
    /// - Returns:  An `Int` value representing the *id* of the (strongly) connected component
    ///             of the given vertex in the queried graph.
    /// - Complexity:   Amortized O(1). It will take O(*V* + *E*) complexity to build this result when
    ///                 queried for the first time, where *V* is the count of vertices of the queried graph,
    ///                 and *E* is the number of edges in the queried graph.
    public func id(of vertex: Int) -> Int {
        precondition(0..<graph.vertexCount ~= vertex, "Vertex: \(vertex) is not in graph.")
        
        return _ids[vertex]
    }
    
    /// Returns an `Array` containing all the vertices (strongly) connected in the component with the given id.
    ///
    /// - Parameter id: The *id* of the (strongly) connected component to obtain.
    ///                 **Must be in range 0..<count**.
    /// - Returns:  An `Array` of `Int` values representing the vertices of the queried graph
    ///             laying in the (strongly) connected component with the given *id*.
    /// - Complexity:   Amortized O(*V*). It will take O(*V* + *E*) complexity to build this result when
    ///                 queried for the first time, where *V* is the count of vertices of the queried graph,
    ///                 and *E* is the number of edges in the queried graph.
    public func stronglyConnectedComponent(with id: Int) -> Array<Int> {
        precondition(0..<count ~= id, "ID \(id) out of bounds.")
        
        if let cached = _memoizedSCC.object(forKey: id as NSNumber) {
            
            return cached as! Array<Int>
        }
        
        let component = (0..<graph.vertexCount)
            .filter { _ids[$0] == id }
        defer {
            _memoizedSCC.setObject(component as NSArray, forKey: id as NSNumber)
        }
        
        return component
    }
    
    /// Returns an `Array` of vertices containing all the vertices (strongly) connected in the queried graph
    ///  to the given one.
    ///
    /// - Parameter vertex: A vertex, **must be in the queried graph**.
    /// - Returns: An `Array` of `Int` values representing the vertices of the queried graph
    ///             in the (strongly) connected component containing the given vertex.
    /// - Complexity:   Amortized O(*V*). It will take O(*V* + *E*) complexity to build this result when
    ///                 queried for the first time, where *V* is the count of vertices of the queried graph,
    ///                 and *E* is the number of edges in the queried graph.
    /// - Note: The returned array will also include the given vertex, since this utility considers
    ///         every vertex of a graph to be connected to itself regardless of the presence of a self loop edge.
    @inlinable
    public func verticesStronglyConnected(to vertex: Int) -> Array<Int> {
        let vertexId = id(of: vertex)
        
        return stronglyConnectedComponent(with: vertexId)
    }
    
    private func _buildData() -> (ids: Array<Int>, count: Int) {
        var ids = Array<Int>(repeating: graph.vertexCount, count: graph.vertexCount)
        var currentID = 0
        var visited = Set<Int>()
        if graph.kind == .undirected {
            // classic Connected Components algorithm for undirected graph:
            for vertex in 0..<graph.vertexCount where !visited.contains(vertex) {
                ids[vertex] = currentID
                graph.recursiveDFS(reachableFrom: vertex, visited: &visited) { currentVertex, edge in
                    let other = edge.other(currentVertex)
                    ids[other] = currentID
                }
                currentID += 1
            }
        } else {
            // Kosaraju-Sharir algorithm for directed graph:
            var reveresedPostOrder = Array<Int>()
            graph.reversed()
                .depthFirstSearch(
                    preOrderVertexVisit: {_ in },
                    visitingVertexAdjacency: {_, _ ,_ in },
                    postOrderVertexVisit: { reveresedPostOrder.append($0) }
                )
            reveresedPostOrder.reverse()
            for vertex in reveresedPostOrder where !visited.contains(vertex) {
                graph.recursiveDFS(reachableFrom: vertex, visited: &visited) { currentVertex in
                    ids[currentVertex] = currentID
                }
                currentID += 1
            }
        }
        
        return (ids, currentID)
    }
    
}
