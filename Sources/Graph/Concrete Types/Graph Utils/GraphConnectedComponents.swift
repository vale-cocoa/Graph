//
//  GraphConnectedComponents.swift
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

/// An utility to query a graph for its connected components.
///
/// Since a graph can contain a huge number of vertices and edges, this utility is a stand-alone class type which
/// gets initialized with the graph to query.
/// Results for queries are calculated lazily the first time a query is made.
/// Note that results are valid for the graph state used at initialization time, thus a new instance must be
/// created to query a mutated graph instance.
public final class GraphConnectedComponents<G: Graph> {
    /// The graph to query.
    public let graph: G
    
    /// The number of connected components found in the queried graph.
    ///
    /// - Complexity:   Amortized O(1). It will take O(*V* + *E*) complexity to build this result when
    ///                 queried for the first time, where *V* is the count of vertices of the queried graph,
    ///                 and *E* is the number of edges in the queried graph.
    public private(set) lazy var count: Int = {
        let data = _buildIds()
        defer {
            _ids = data.ids
        }
        
        return data.countOfComponents
    }()
    
    private lazy var _ids: Array<Int> = {
        let data = _buildIds()
        defer {
            count = data.countOfComponents
        }
        
        return data.ids
    }()
    
    private var _memoizedComponents = NSCache<NSNumber, NSArray>()
    
    /// Returns a new instance of `GraphConnectedComponents` initalized with the given graph.
    ///
    /// - Parameter graph: Some `Graph` instance.
    /// - Returns: A new `GraphConnectedComponents` instance.
    /// - Complexity: O(1).
    public init(graph: G) {
        self.graph = graph
    }
    
    /// Return true if the two given vertices are connected in the queried graph, otherwise false.
    ///
    /// - Parameter v: A vertex, **must be in the queried graph**.
    /// - Parameter w: A vertex, **must be in the queried graph**.
    /// - Returns:  A boolean value, true if the two given vertices are connected in the queried graph,
    ///             false otherwise. When the two given vertices are the same one, then this method
    ///             always returns true. That is, this utility considers every vertex of the queried graph to
    ///             be connected to itself regardless of the presence of a self loop edge.
    /// - Complexity:   Amortized O(1). It will take O(*V* + *E*) complexity to build this result when
    ///                 queried for the first time, where *V* is the count of vertices of the queried graph,
    ///                 and *E* is the number of edges in the queried graph.
    public func areConnected(_ v: Int, _ w: Int) -> Bool {
        precondition(0..<graph.vertexCount ~= v, "Vertex: \(v) is not in graph.")
        precondition(0..<graph.vertexCount ~= w, "Vertex: \(w) is not in graph.")
        
        return _ids[v] == _ids[w]
    }
    
    /// Returns an `Int` value in range `0..<count` representing the id of the connected component of
    /// the given vertex in the queried graph.
    ///
    /// - Parameter vertex: A vertex, **must be in the queried graph**.
    /// - Returns:  An `Int` value representing the id of the connected component of the given vertex in
    ///             the queried graph.
    /// - Complexity:   Amortized O(1). It will take O(*V* + *E*) complexity to build this result when
    ///                 queried for the first time, where *V* is the count of vertices of the queried graph,
    ///                 and *E* is the number of edges in the queried graph.
    public func id(of vertex: Int) -> Int {
        precondition(0..<graph.vertexCount ~= vertex, "Vertex: \(vertex) is not in graph.")
        
        return _ids[vertex]
    }
    
    /// Returns an `Array` containing all the vertices connected in the component with the given id.
    ///
    /// - Parameter id: The id of the connected component to obtain. **Must be in range 0..<count**.
    /// - Returns:  An `Array` of `Int` values representing the vertices of the queried graph
    ///             in the connected component with the given id.
    /// - Complexity:   Amortized O(1). It will take O(*V* + *E*) complexity to build this result when
    ///                 queried for the first time, where *V* is the count of vertices of the queried graph,
    ///                 and *E* is the number of edges in the queried graph.
    public func component(with id: Int) -> Array<Int> {
        precondition(0..<count ~= id, "ID: \(id) out of bounds.")
        
        let key = NSNumber(value: id)
        if let cached = _memoizedComponents.object(forKey: key) {
            
            return cached.map { ($0 as! NSNumber).intValue }
        }
        
        let component = (0..<graph.vertexCount)
            .filter { _ids[$0] == id }
        defer {
            let cached = component.map { NSNumber(value: $0) } as NSArray
            _memoizedComponents.setObject(cached, forKey: key)
        }
        
        return component
    }
    
    /// Returns an `Array` of vertices containing all the vertices connected in the queried graph to the given one.
    ///
    /// - Parameter vertex: A vertex, **must be in the queried graph**.
    /// - Returns: An `Array` of `Int` values representing the vertices of the queried graph
    ///             in the connected component containing the given vertex.
    /// - Complexity:   Amortized O(1). It will take O(*V* + *E*) complexity to build this result when
    ///                 queried for the first time, where *V* is the count of vertices of the queried graph,
    ///                 and *E* is the number of edges in the queried graph.
    /// - Note: The returned array will also include the given vertex, since this utility considers
    ///         every vertex of a graph to be connected to itself regardless of the presence of a self loop edge.
    public func verticesConnected(to vertex: Int) -> Array<Int> {
        let vertexId = id(of: vertex)
        
        return component(with: vertexId)
    }
    
    private func _buildIds() -> (ids: Array<Int>, countOfComponents: Int) {
        var ids = Array<Int>(repeating: graph.vertexCount, count: graph.vertexCount)
        var currentID = 0
        var visited = Set<Int>()
        for vertex in 0..<graph.vertexCount where !visited.contains(vertex) {
            ids[vertex] = currentID
            graph.recursiveDFS(reachableFrom: vertex, visited: &visited) { currentVertex, edge in
                let other = edge.other(currentVertex)
                ids[other] = currentID
            }
            currentID += 1
        }
        
        return (ids, currentID)
    }
    
}


