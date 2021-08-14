//
//  GraphDijkstraSP.swift
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
import IndexedPriorityQueue

/// A utility to query a weighted graph for the shortest paths from a source vertex to other vertices.
///
/// Since a graph can contain a huge number of vertices and edges, this utility is a stand-alone class type which
/// gets initialized with the weighted graph to query and the source vertex.
/// Results for queries are calculated lazily the first time a query is made.
/// Note that results are valid for the graph state used at initialization time, thus a new instance must be
/// created to query a mutated graph instance
/// - Note: This utility adopts the Dijkstra algorithm, therefore overall complexity will be
///          O(?) for the first query, and **edges weight values must not be negative.**
///         That is Dijkstra algorithm not get correctly shortests paths in presence of negative weight values
///         or worst get into an infinite loop if the graph contains a negative cycle.
public final class GraphDijkstraSP<G: Graph> where G.Edge: WeightedGraphEdge {
    /// Error thrown by `GraphDijkstraSP ` utility.
    public enum Error: Swift.Error {
        /// This error is thrown if the queried graph contains a weighted edge with negative weight value
        /// and such edge is encoutered while building up the shortest paths.
        case negativeWeightedEdge
        
    }
    
    /// The graph to query.
    public let graph: G
    
    /// The source vertex to query.
    public let source: Int
    
    fileprivate lazy var _edgeTo: Result<Array<G.Edge?>, Error> = {
        let (edgeTo, weightTo) = _buildShortestPaths()
        defer {
            self._weightTo = weightTo
        }
        
        return edgeTo
    }()
    
    fileprivate lazy var _weightTo: Result<Array<G.Edge.Weight?>, Error> = {
        let (edgeTo, weightTo) = _buildShortestPaths()
        defer {
            self._edgeTo = edgeTo
        }
        
        return weightTo
    }()
    
    fileprivate let _memoizedSP = NSCache<NSNumber, NSArray>()
    
    
    /// Returns a new `GraphDijkstraSP` instance initialized to the given graph and the given source values.
    ///
    /// - Parameter graph: Some `Graph` instance, **must have vertexCount value grater than 0**.
    /// - Parameter source: A vertex, **must be included in given graph**.
    /// - Returns: A new `GraphDijkstraSP` instance intialized to the specified parameters.
    /// - Complexity: O(1)
    public init(graph: G, source: Int) {
        precondition(0..<graph.vertexCount ~= source, "source must be a vertex in graph.")
        
        self.graph = graph
        self.source = source
    }
    
}

extension GraphDijkstraSP {
    /// Returns the total weight to reach given destination vartex in queried graph from source vertex,
    /// `nil` when such vertex is not reachable from source vertex of a shortest path couldn't be calculated.
    ///
    /// - Parameter vertex: The destination vertex. **Must be included in queried graph**.
    /// - Throws:   Throws a `.negativeWeightedEdge` error in case the queried graph contains a weighted edge
    ///             with negative weight value and such edge is discovered while building up shortest paths.
    ///             **This utility only works for querying edge weighted graphs with non-negative weights.**
    /// - Returns:  The total weight of the shortest path from the queried source vertex to the given
    ///             destination vertex if such path exists in queried graph otherwise `nil`.
    /// - Complexity:   O(*E* *V*) where *E* is the count of edges and *V* is the count of vertices
    ///                 in the queried graph when queried for the first time, then O(1) for subsequent queries.
    public func weight(to vertex: Int) throws -> G.Edge.Weight? {
        precondition(0..<graph.vertexCount ~= vertex, "Destination vertex must be in graph.")
        guard
            case .success(let weightTo) = _weightTo
        else { throw Error.negativeWeightedEdge }
        
        return weightTo.withUnsafeBufferPointer({ $0[vertex] })
    }
    
    /// Returns `true` if there is a path in queried graph connecting the queried source vertex to
    /// the given destination vertex; otherwise `false`.
    ///
    /// - Parameter vertex: The destination vertex. **Must be included in queried graph**.
    /// - Throws:   Throws a `.negativeWeightedEdge` error in case the queried graph contains a weighted edge
    ///             with negative weight value and such edge is discovered while building up shortest paths.
    ///             **This utility only works for querying edge weighted graphs with non-negative weights.**
    /// - Returns:  A boolean value: `true` if there is a path connecting the queried source
    ///             and the given destination vertices in the queried graph, otherwise `false`.
    /// - Complexity:   O(*E* *V*) where *E* is the count of edges and *V* is the count of vertices
    ///                 in the queried graph when queried for the first time, then O(1) for subsequent queries.
    public func hasPath(to vertex: Int) throws -> Bool {
        precondition(0..<graph.vertexCount ~= vertex, "Destination vertex must be in graph.")
        guard
            case .success(let weightTo) = _weightTo
        else { throw Error.negativeWeightedEdge }
        
        return weightTo.withUnsafeBufferPointer({ $0[vertex] }) != nil
    }
    
    /// Returns a sequence of edges representing the shortest path in the queried graph
    /// going from the queried source to the given destination verticies.
    /// Such sequence will be empty if there is not such path.
    ///
    /// - Parameter vertex: The destination vertex. **Must be included in queried graph**.
    /// - Throws:   Throws a `.negativeWeightedEdge` error in case the queried graph contains a weighted edge
    ///             with negative weight value and such edge is discovered while building up shortest paths.
    ///             **This utility only works for querying edge weighted graphs with non-negative weights.**
    /// - Returns:  A sequence of edges representing the shortest path in the queried graph
    ///             going from the queried source to the given destination verticies.
    ///             Such sequence will be empty if there is not such path.
    /// - Complexity:   O(*E* *V*) where *E* is the count of edges and *V* is the count of vertices
    ///                 in the queried graph when queried for the first time,
    ///                 then amortized O(1) for subsequent queries.
    public func path(to vertex: Int) throws -> AnySequence<G.Edge> {
        precondition(0..<graph.vertexCount ~= vertex, "Destination vertex must be in graph.")
        guard
            case .success(let edgeTo) = _edgeTo
        else { throw Error.negativeWeightedEdge }
        
        guard
            edgeTo.withUnsafeBufferPointer({ $0[vertex] }) != nil
        else { return AnySequence(EmptyCollection()) }
        
        let base: Array<G.Edge>!
        if let cached = _memoizedSP.object(forKey: NSNumber(integerLiteral: vertex)) as? Array<G.Edge> {
            
            base = cached
        } else {
            var reversedPath = Array<G.Edge>()
            var from = vertex
            
            while let edge = edgeTo.withUnsafeBufferPointer({ $0[from] }) {
                reversedPath.append(edge)
                from = edge.other(from)
            }
            defer {
                _memoizedSP.setObject(reversedPath as NSArray, forKey: NSNumber(integerLiteral: vertex))
            }
            
            base = reversedPath
        }
        
        return AnySequence(base.lazy.reversed())
    }
    
}

extension GraphDijkstraSP {
    fileprivate func _buildShortestPaths() -> (edgeTo: Result<Array<G.Edge?>, Error>, weightTo: Result<Array<G.Edge.Weight?>, Error>) {
        var edgeTo = Array<G.Edge?>(repeating: nil, count: graph.vertexCount)
        var weightTo = Array<G.Edge.Weight?>(repeating: nil, count: graph.vertexCount)
        weightTo[source] = .zero
        guard
            graph.edgeCount > 0
        else { return (.success(edgeTo), .success(weightTo)) }
        
        var pq = IndexedPriorityQueue<G.Edge.Weight>(minimumCapacity: graph.vertexCount, sort: <)
        let relax: (Int) throws -> Void = { [graph] vertex in
            for edge in graph.adjacencies(vertex: vertex) {
                guard
                    edge.weight >= .zero
                else { throw Error.negativeWeightedEdge }
                
                let other = edge.other(vertex)
                if let vertexW = weightTo[vertex] {
                    if weightTo[other] == nil || weightTo[other]! > vertexW + edge.weight {
                        weightTo[other] = vertexW + edge.weight
                        edgeTo[other] = edge
                        pq[other] = weightTo[other]!
                    }
                }
            }
        }
        
        pq[source] = .zero
        while let v = pq.popTopMost()?.key {
            do {
                try relax(v)
            } catch {
                
                return (.failure(error as! Error), .failure(error as! Error))
            }
        }
        
        return (.success(edgeTo), .success(weightTo))
    }
    
}
