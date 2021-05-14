//
//  GraphCycle.swift
//  Graph
//
//  Created by Valeriano Della Longa on 2021/04/29.
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

/// An utility to query a graph for either containig a cycle or not.
///
/// Since a graph can contain a huge number of vertices and edges, this utility is a stand-alone class type which
/// gets initialized with the graph to query.
/// Results for queries are calculated lazily the first time a query is made.
/// Note that results are valid for the graph state used at initialization time, thus a new instance must be
/// created to query a mutated graph instance.
public final class GraphCycle<G: Graph> {
    /// The graph to query.
    public let graph: G
    
    /// Returns an array containing the first cycle detected in the queried graph, as vertices.
    ///
    /// - Note: In case the queried graph contains a cycle, the array returned by this method will contain the vertices
    ///         in the order of the cycle.
    /// - Complexity:   Amortized O(1). It will take O(*V* + *E*) complexity to build this result when
    ///                 queried for the first time, where *V* is the count of vertices of the queried graph,
    ///                 and *E* is the number of edges in the queried graph.
    public private(set) lazy var cycle: Array<Int> = {
        let data = _buildData()
        defer {
            topologicalSort = data.topologicalSort
        }
        
        return data.cycle
    }()
    
    /// Returns an array of vertices as topological sort of the queried graph, when such graph is
    /// of kind `.directed` and has no cycle, otherwise `nil`.
    ///
    /// - Complexity:   Amortized O(1). It will take O(*V* + *E*) complexity to build this result when
    ///                 queried for the first time, where *V* is the count of vertices of the queried graph,
    ///                 and *E* is the number of edges in the queried graph.
    public private(set) lazy var topologicalSort: Array<Int>? = {
        let data = _buildData()
        defer {
            cycle = data.cycle
        }
        
        return data.topologicalSort
    }()
    
    /// A boolean value, true when the queried graph has a cycle, false otherwise.
    ///
    /// - Complexity:   Amortized O(1). It will take O(*V* + *E*) complexity to build this result when
    ///                 queried for the first time, where *V* is the count of vertices of the queried graph,
    ///                 and *E* is the number of edges in the queried graph.
    @inlinable
    public var hasCycle: Bool { !cycle.isEmpty }
    
    /// Returns a new instance of `GraphCycle` initalized with the given graph.
    ///
    /// - Parameter graph: Some `Graph` instance.
    /// - Returns: A new `GraphCycle` instance.
    /// - Complexity: O(1).
    public init(graph: G) {
        self.graph = graph
    }
    
    private func _buildData() -> (cycle: Array<Int>, topologicalSort: Array<Int>?) {
        var visited = Set<Int>()
        var cycleStack: Array<Int> = []
        var edgeTo = Array<Int?>(repeating: nil, count: graph.vertexCount)
        var isOnStack = Set<Int>()
        var reversePostOrderStack: Array<Int> = []
        for vertex in 0..<graph.vertexCount where !visited.contains(vertex) {
            var parent: Int? = nil
            var previousParents: Array<Int?> = []
            graph.recursiveDFS(
                reachableFrom: vertex,
                visited: &visited,
                preOrderVertexVisit: {
                    guard cycleStack.isEmpty else { return }
                    
                    if graph.kind == .directed {
                        isOnStack.insert($0)
                    }
                },
                visitingVertexAdjacency: { currentVertex, edge, hasBeenVisited in
                    guard cycleStack.isEmpty else { return }
                    
                    let other = edge.other(currentVertex)
                    if !hasBeenVisited {
                        edgeTo[other] = vertex
                        if graph.kind == .undirected {
                            previousParents.append(parent)
                            parent = currentVertex
                        }
                    } else if
                        (graph.kind == .directed && isOnStack.contains(other)) ||
                            (graph.kind == .undirected && parent != other)
                    {
                        var current = currentVertex
                        while current != other {
                            cycleStack.append(current)
                            current = edgeTo[current]!
                        }
                        cycleStack.append(other)
                        cycleStack.append(currentVertex)
                    }
                },
                postOrderVertexVisit: {
                    guard cycleStack.isEmpty else { return }
                    
                    if graph.kind == .directed {
                        isOnStack.remove($0)
                        reversePostOrderStack.append($0)
                    } else {
                        parent = previousParents.popLast() ?? nil
                    }
                }
            )
            guard cycleStack.isEmpty else { break }
        }
        
        let sort: Array<Int>? = (graph.kind == .directed && cycleStack.isEmpty) ? reversePostOrderStack.reversed() : nil
        
        return (cycleStack.reversed(), sort)
    }
    
}
