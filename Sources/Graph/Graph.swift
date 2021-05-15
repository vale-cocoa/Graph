//
//  Graph.swift
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

/// A graph representation using a range of `Int` values as its *vertices*, generic over the `Edge` type
/// used to represents its *edges*.
public protocol Graph: Hashable {
    /// The Type of *edge* used in this graph, conforming to `GraphEdge` protocol.
    ///
    /// - Note: When the concrete type conforming to `Graph` has its associated
    ///         `Edge` type conforming to `WeightedGraphEdge` protocol,
    ///         then the graph is a *weighted graph* and its *edges* express also
    ///         a `weight` value.
    ///         The `weight` value of such *weighted edges* represents
    ///         the *weight* or*cost* of the connection the *edge* expresses
    ///         between those two *vertices* of the graph.
    associatedtype Edge: GraphEdge
    
    /// The kind of represented graph, either **directed** when its value is equal to `.directed`
    /// or **undirected** when equals to `.undirected`.
    ///
    /// A conforming type must differentate how edges are handled based on this value.
    /// - Complexity: O(1).
    var kind: GraphConnections { get }
    
    /// The number of vertices for this graph, that is vertices in this graph are `Int` values in the
    /// range `0..<vertexCount`.
    ///
    /// - Complexity: O(1).
    var vertexCount: Int { get }
    
    /// An `Int` value equivalent to the number of edges in this graph.
    ///
    /// Conforming types must return the appropriate value taking into account the `kind`
    /// value of the instance.
    /// That is, a graph with a `kind` value of `undirected` must return
    /// this value counting edges as **undirected edges**, even if internally it represents such
    /// connections with two edges having opposite directions.
    /// On the other hand, for `kind` value of `directed` it must return the number of
    /// **directed edges** edges it stores.
    /// - Complexity: O(1).
    var edgeCount: Int { get }
    
    /// Create a new graph of the specified kind from the given edges.
    ///
    /// - Parameter kind: A `GraphConnections` value.
    /// - Parameter edges: An array containing the edges of the new graph.
    /// - Returns: A graph of the specified kind, containing the given edges.
    init(kind: GraphConnections, edges: [Edge])
    
    /// Returns all vertices in this graph adjacent to the given one, as an array of edges.
    /// If the vertex is *disconnected* from other vertices in the graph,
    /// this method will then return an empty array.
    ///
    /// - Parameter vertex: A vertex of this graph, **must be** contained in
    ///                     the `vertices` range of this graph.
    /// - Returns: An array of edges to the vertices in this graph adjacent to the given one.
    /// - Precondition: `vertex` parameter must be included in `vertices`.
    /// - Complexity:   Conforming types are supposed to be O(1).
    ///                 A deviation from such performance **must** be documented since other
    ///                 default implementations and generic graph utilities rely
    ///                 on this method being O(1) complexity.
    /// - Note: Independetly of the `kind` value of the graph, the edges returned by this method
    ///         can be safely queried for the neighbour vertex by using the
    ///         `GraphEdge` method `other(_:)`passing `vertex` as parameter:
    /// ```Swift
    /// // Assuming g is a graph and v is a vertex with adjacencies:
    /// let adjs = g.adjacencies(vertex: v)
    /// for edge in adjs {
    ///     print(edge.other(v))
    ///     // Always prints the neighbour vertex to v in the graph.
    /// }
    /// ```
    ///     That is, a graph with `kind` value of `.undirected` returns edges that
    ///     must be considered **undirected edges**, hence the value stored as
    ///     `either` in the edge might be swapped in regard to the queried
    ///     `vertex` parameter value passed to `adjacencies(vertex:)` method.
    func adjacencies(vertex: Int) -> [Edge]
    
    /// Returns a new graph instance with reversed edges.
    ///
    /// This method has particular importance for graphs whose `kind` property value is `.directed`
    /// in order to obtain the inversion of a **direct graph**.
    /// Conversely, graphs whose `kind` property value is `.undirected` have their inverted graph
    /// corresponding to the same graph since their vertices' connections are bi-directional.
    /// In the following example is shown the beahvior of this method on a **direct graph**:
    /// ```Swift
    /// // supposing `g` is a graph where g.kind == .directed,
    /// // g.vertices = 0..<10, g.edgeCount = 3,
    /// // g.adjacencies(vertex: 2) == [(tail: 2, head: 5)]
    /// // g.adjacencies(vertex: 3) == [(tail: 3, head: 2)]
    /// // g.adjacencies(vertex: 5) == [(tail: 5, head: 3)]
    /// let gInverse = g.reversed()
    ///
    /// print(gInverse.edgeCount)
    /// // prints: "3"
    ///
    /// print(gInverse.adjacencies(vertex: 2))
    /// // prints: "[(tail: 2, head: 3)]"
    ///
    /// print(gInverse.adjacencies(vertex: 3))
    /// // prints: "[(tail: 3, head: 5)]"
    ///
    /// print(gInverse.adjacencies(vertex: 5))
    /// // prints: "[(tail: 5, head: 2)]"
    /// ```
    ///
    /// - Returns: A new graph with inverted edges of callee.
    /// - Complexity:   O(*V* + *E*) where *V*  is the count of vertices in the graph,
    ///                 and*E* is the number of edges in the graph.
    func reversed() -> Self
    
}

