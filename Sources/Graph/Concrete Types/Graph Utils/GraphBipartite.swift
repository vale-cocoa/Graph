//
//  GraphIsBipartite.swift
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

/// An utility to query a graph about it being bipartite or not.
///
/// Since a graph can contain a huge number of vertices and edges, this utility is a stand-alone class type which
/// gets initialized with the graph to query. Results for queries are calculated lazily the first time either a `isBipartite`
/// or a `isColored(_:)` query is made.
/// Note that results are valid for the graph state used at initialization time, thus a new instance must be
/// created to query a mutated graph instance.
public final class GraphBipartite<G: Graph> {
    /// The graph to query.
    public let graph: G
    
    /// A boolean value, true when the queried graph is bipartite, otherwise false.
    ///
    /// - Note: When the queried graph has no edges, then the returned value is always `true`.
    /// - Complexity:   Amortized O(1). It will take O(*V* + *E*) complexity to build this result when
    ///                 queried for the first time, where *V* is the count of vertices of the queried graph,
    ///                 and *E* is the number of edges in the queried graph.
    public private(set) lazy var isBiPartite: Bool = {
        let data = _buildData()
        defer {
            hasColor = data.colored
        }
        
        return data.isBipartite
    }()
    
    /// The number of vertices which have been colored during the calculation of the `isBipartite` value.
    ///
    /// - Note: If the queried graph has no edges, then this value is `0`.
    /// - Complexity:   Amortized O(1). It will take O(*V* + *E*) complexity to build this result when
    ///                 queried for the first time, where *V* is the count of vertices of the queried graph,
    ///                 and *E* is the number of edges in the queried graph.
    public private(set) lazy var countOfColoredVertex: Int = {
        hasColor.filter({ $0 }).count
    }()
    
    /// The number of vertices which have not been colored during the calculation of the `isBipartite` value.
    ///
    /// - Note: If the queried graph has no edges, then this value matches the count of vertices in the graph.
    /// - Complexity:   Amortized O(1). It will take O(*V* + *E*) complexity to build this result when
    ///                 queried for the first time, where *V* is the count of vertices of the queried graph,
    ///                 and *E* is the number of edges in the queried graph.
    public private(set) lazy var countOfNotColoredVertex: Int = {
        hasColor.filter({ !$0 }).count
    }()
    
    private lazy var hasColor: Array<Bool> = {
        let data = _buildData()
        defer {
            isBiPartite = data.isBipartite
        }
        
        return data.colored
    }()
    
    /// Returns a new instance of `GraphBipartite` initalized with the given graph.
    ///
    /// - Parameter graph: Some `Graph` instance.
    /// - Returns: A new `GraphBipartite` instance.
    /// - Complexity: O(1).
    public init(graph: G) {
        self.graph = graph
    }
    
    /// Returns a boolean value, true when the given vertex was colored during the calculation of
    /// the `isBipartite` value, otherwise `false`. When the queried graph has no edges, then the returned
    /// value is `false` for every given vertex.
    ///
    /// - Parameter vertex: A vertex of the graph. **Must be in range 0..<graph.vertexCount**.
    /// - Returns: A boolean value, true if the given vertex has color in the bipartite construction.
    /// - Complexity: Amortized O(1). It will take O(*V* + *E*) complexity to build this result when
    ///                 queried for the first time, where *V* is the count of vertices of the queried graph,
    ///                 and *E* is the number of edges in the queried graph.
    public func isColored(_ vertex: Int) -> Bool {
        precondition(0..<graph.vertexCount ~= vertex, "Vertex: \(vertex) is not in graph.")
        
        return hasColor[vertex]
    }
    
    private func _buildData() -> (isBipartite: Bool, colored: Array<Bool>) {
        var colored = Array<Bool>(repeating: false, count: graph.vertexCount)
        var biPartiteResult = true
        guard graph.edgeCount > 0 else { return (biPartiteResult, colored) }
        
        graph.depthFirstSearch(
            preOrderVertexVisit: { _ in },
            visitingVertexAdjacency: { vertex, edge, isVisited in
                let other = edge.other(vertex)
                if !isVisited {
                    colored[other] = !colored[vertex]
                } else if colored[other] == colored[vertex] {
                    biPartiteResult = false
                }
            },
            postOrderVertexVisit: { _ in }
        )
        
        return (biPartiteResult, colored)
    }
    
}

