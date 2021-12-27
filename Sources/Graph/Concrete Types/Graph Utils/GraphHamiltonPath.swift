//
//  GraphHamiltonPath.swift
//  Graph
//
//  Created by Valeriano Della Longa on 2021/12/15.
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

/// A utility to query a graph for Hamilton paths.
///
/// Since a graph can contain a huge number of vertices and edges, this utility is a stand-alone class type which
/// gets initialized with the graph to query.
/// Results for queries are calculated lazily the first time a query is made.
/// Note that results are valid for the graph state used at initialization time, thus a new instance must be
/// created to query a mutated graph instance
public final class GraphHamiltonPath<G: Graph> {
    
    /// The graph to query.
    public let graph: G
    
    /// An array containing all the Hamilton paths in the queried graph.
    ///
    /// Each element of this array is an array of edges representing an hamiltonian path
    /// found in the queried graph; that is every element contains a sequence of edges representing
    /// a path in the graph that visits each of its vertices only once.
    /// - Complexity:   O(*V* \* *E*) where *V* and *E* are respectively
    ///                 the count of vertices and the count of edges in the queried graph.
    public fileprivate(set) lazy var hamiltonianPaths: Array<Array<G.Edge>> = _findHamiltonianPaths()
    
    
    public init(graph: G) {
        self.graph = graph
    }
    
}

extension GraphHamiltonPath {
    fileprivate func _findHamiltonianPaths() -> Array<Array<G.Edge>> {
        guard
            graph.vertexCount > 0,
            graph.edgeCount > 0
        else { return [] }
        
        var visited = Set<Int>()
        var paths = Array<Array<G.Edge>>()
        func _dfs(v: Int, depth: Int, currentPath: Array<G.Edge>) {
            visited.insert(v)
            if depth == graph.vertexCount {
                paths.append(currentPath)
            }
            for edge in graph.adjacencies(vertex: v) {
                let w = edge.other(v)
                if !visited.contains(w) {
                    _dfs(v: w, depth: depth + 1, currentPath: currentPath + [edge])
                }
            }
            visited.remove(v)
        }
        
        for vertex in 0..<graph.vertexCount {
            _dfs(v: vertex, depth: 1, currentPath: [])
        }
        
        return paths
    }
    
}

