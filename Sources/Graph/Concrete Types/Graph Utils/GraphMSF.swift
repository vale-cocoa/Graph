//
//  GraphMSF.swift
//  Graph
//
//  Created by Valeriano Della Longa on 2021/07/13.
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
import PriorityQueue
import IndexedPriorityQueue
import UnionFind

/// A utility to query a weighted undirected graph for its minimum spanning forest.
///
/// Since a graph can contain a huge number of vertices and edges, this utility is a stand-alone class type which
/// gets initialized with the weighted graph to query.
/// Results for queries are calculated lazily the first time a query is made.
/// Note that results are valid for the graph state used at initialization time, thus a new instance must be
/// created to query a mutated graph instance
public final class GraphMSF<G: Graph> where G.Edge: WeightedGraphEdge {
    
    /// The algorithm to use for building up the minimum sparring forest of the queried graph.
    ///
    /// - Todo: Perhaps also add Chazelle algorithm.
    public enum Algorithm: CaseIterable {
        /// Lazy version of Prim's algorithm to build the minimum spanning tree of a graph connected component.
        ///
        /// - Complexity: O(*E* log *V*) where *E* is the count of edges and *V* is the count
        ///                 of vertices of the queried graph.
        case primLazyAlgorithm
        
        /// Eager version of Prim's algorithm to build the minimum spanning tree of a graph connected component.
        ///
        /// - Complexity: O(*E * log *E*) where *E* is the count of edges of the queried graph.
        case primEagerAlgorithm
        
        /// Kruskal's algorithm to build the minimum spanning tree of a graph connected component.
        ///
        /// - Complexity: O(*E* log *E*) where *E* is the count of edges of the queried graph.
        case kruskalAlgorithm
        
    }
    
    /// The graph to query.
    public let graph: G
    
    /// The algorithm to use for building up the minimum sparring forest of the queried graph.
    public let algorithm: Algorithm
    
    /// The minimum sparring forest of the queried graph, `nil` when the queried graph is of type `.directed`.
    ///
    /// Each element of this array is the minimum spanning tree for a connected component of the queried graph.
    /// Such minimum spaning tree is represented via an array of edges of the queried graph.
    /// - Complexity: Refer to the algorithm in use by the `GraphMSF` instance.
    /// - Note: Indices values of this array correspond to `id` values of the connected components
    ///         of the queried graph.
    public fileprivate(set) lazy var msf: Array<Array<G.Edge>>? = {
        let data = _buildMSFAndWeights()
        defer {
            weights = data?.weights
        }
        
        return data?.msf
    }()
    
    /// The weights of each connected component's minium spanning tree in the queried graph, `nil`
    /// when the queried graph is of type `.directed`.
    ///
    /// Each element of this array is the weight of the minimum spanning tree for a connected component
    /// of the queried graph. Such weight is `nil` when the connected component is formed by just one
    /// vertex, hence corresponding to an empty minimum spanning tree.
    /// - Complexity: Refer to the algorithm in use by the `GraphMSF` instance.
    /// - Note: Indices values of this array correspond to `id` values of the connected components
    ///         of the queried graph.
    public fileprivate(set) lazy var weights: Array<G.Edge.Weight?>? = {
        let data = _buildMSFAndWeights()
        defer {
            msf = data?.msf
        }
        
        return data?.weights
    }()
    
    /// Returns a new instance of `GraphMSF` initalized with the given graph and to adopt given algorithm for building
    /// the minimum spanning tree of each connected component of the queried graph.
    ///
    /// - Parameter graph: Some `Graph` instance.
    /// - Parameter algorithm:  The algorithm adopted by this instance of `GraphMSF` to build each
    ///                         minimum spanning tree of the queried graph connected components.
    /// - Returns: A new `GraphMSF` instance to query the given graph adopting the given algorithm.
    /// - Complexity: O(1).
    public init(graph: G, adopting algorithm: Algorithm) {
        self.graph = graph
        self.algorithm = algorithm
    }
    
}

// MARK: - Fileprivate helpers
extension GraphMSF {
    fileprivate func _buildMSFAndWeights() -> (msf: Array<Array<G.Edge>>, weights: Array<G.Edge.Weight?>)? {
        guard
            graph.kind == .undirected
        else { return nil }
        
        guard
            graph.vertexCount > 0,
            graph.edgeCount > 0
        else {
            return (Array(repeating: [], count: graph.vertexCount), Array(repeating: nil, count: graph.vertexCount))
        }
        
        switch algorithm {
        case .primLazyAlgorithm: return _primLazyAlgorithm()
        case .primEagerAlgorithm: return _primEagerAlgorithm()
        case .kruskalAlgorithm: return _kruskalAlgorithm()
        }
    }
    
}

// MARK: - Prim's lazy algorithm
extension GraphMSF {
    fileprivate func _primLazyAlgorithm() -> (msf: Array<Array<G.Edge>>, weights: Array<G.Edge.Weight?>) {
        var _msf = Array<Array<G.Edge>>()
        var _weights = Array<G.Edge.Weight?>()
        
        var pq = PriorityQueue<G.Edge>(minimumCapacity: graph.edgeCount, sort: {
            $0.weight < $1.weight
        })
        var visited: Set<Int> = []
        let visit: (Int) -> Void = { [graph] u in
            visited.insert(u)
            for edge in graph.adjacencies(vertex: u) {
                let other = edge.other(u)
                if !visited.contains(other) {
                    pq.enqueue(edge)
                }
            }
        }
        
        var mst = Deque<G.Edge>()
        mst.reserveCapacity(graph.edgeCount)
        for vertex in 0..<graph.vertexCount where !visited.contains(vertex) {
            mst.removeAll(keepingCapacity: true)
            var _mstWeight: G.Edge.Weight? = nil
            visit(vertex)
            while let edge = pq.dequeue() {
                let v = edge.either
                let w = edge.other(v)
                guard
                    !visited.contains(v) || !visited.contains(w)
                else { continue }
                
                mst.enqueue(edge)
                if let runningWeight = _mstWeight {
                    _mstWeight = runningWeight + edge.weight
                } else {
                    _mstWeight = edge.weight
                }
                if !visited.contains(v) {
                    visit(v)
                }
                if !visited.contains(w) {
                    visit(w)
                }
            }
            _msf.append(Array(mst))
            _weights.append(_mstWeight)
        }
        
        return (_msf, _weights)
    }
    
}

// MARK: - Prim's eager algorithm
extension GraphMSF {
    fileprivate func _primEagerAlgorithm() -> (msf: Array<Array<G.Edge>>, weights: Array<G.Edge.Weight?>) {
        var _msf = Array<Array<G.Edge>>()
        var _weights = Array<G.Edge.Weight?>()
        
        var _visited: Set<Int> = []
        var _edgeTo = Array<G.Edge?>(repeating: nil, count: graph.vertexCount)
        var _distTo = Array<G.Edge.Weight?>(repeating: nil, count: graph.vertexCount)
        var _pq = IndexedPriorityQueue<G.Edge.Weight?>.init(minimumCapacity: graph.vertexCount, sort: { lhs, rhs in
            if let l = lhs {
                guard let r = rhs else { return true }
                
                return l < r
            } else {
                
                return rhs == nil
            }
        })
        
        let visit: (Int) -> Void = { [graph] u in
            _visited.insert(u)
            for edge in graph.adjacencies(vertex: u) {
                let w = edge.other(u)
                guard !_visited.contains(w) else { continue }
                
                if _distTo[w] == nil || edge.weight < _distTo[w]! {
                    _edgeTo[w] = edge
                    _distTo[w] = edge.weight
                    _pq[w] = _distTo[w]
                }
            }
        }
        
        for vertex in 0..<graph.vertexCount where !_visited.contains(vertex) {
            _edgeTo = Array<G.Edge?>(repeating: nil, count: graph.vertexCount)
            _distTo = Array<G.Edge.Weight?>(repeating: nil, count: graph.vertexCount)
            _pq[vertex] = .some(nil)
            while let v = _pq.popTopMost()?.key {
                visit(v)
            }
            let _mst = _edgeTo.compactMap({ $0 })
            _msf.append(_mst)
            let _mstWeight: G.Edge.Weight? = _mst.reduce(nil) { result, edge in
                guard let runningResult = result else { return edge.weight }
                
                return runningResult + edge.weight
            }
            _weights.append(_mstWeight)
        }
        
        return(_msf, _weights)
    }
    
}

// MARK: - Kruskal's algorithm
extension GraphMSF {
    fileprivate func _kruskalAlgorithm() -> (msf: Array<Array<G.Edge>>, weights: Array<G.Edge.Weight?>) {
        var _msf = Array<Array<G.Edge>>()
        var _weights = Array<G.Edge.Weight?>()
        var _visited: Set<Int> = []
        
        for vertex in 0..<graph.vertexCount where !_visited.contains(vertex) {
            // Build component for current graph vertex being visited, and
            // store its edges in a priority queue:
            var _pq = PriorityQueue<G.Edge>(minimumCapacity: graph.edgeCount, sort: { $0.weight < $1.weight })
            let _component = graph.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: vertex) { _, _, edge, _ in
                _pq.enqueue(edge)
            }
            
            // Build MST and its weight value for current component:
            var _uf = UnionFind(graph.vertexCount)
            var _mst = Array<G.Edge>()
            var _mstWeight: G.Edge.Weight? = nil
            while
                let edge = _pq.dequeue(),
                _mst.count < (_component.count - 1)
            {
                let v = edge.either
                let w = edge.other(v)
                guard
                    _uf.areConnected(v, w) == false
                else { continue }
                
                _uf.union(v, w)
                _mst.append(edge)
                if let runningWeight = _mstWeight {
                    _mstWeight = runningWeight + edge.weight
                } else {
                    _mstWeight = edge.weight
                }
            }
            
            // Append to MSF this component's MST and to weights its total weight
            _msf.append(_mst)
            _weights.append(_mstWeight)
            
            // Add components' vertices to visited vertices
            _visited.formUnion(_component)
        }
        
        return (_msf, _weights)
    }
    
}
