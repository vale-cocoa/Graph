//
//  MutableGraph.swift
//  Graph
//
//  Created by Valeriano Della Longa on 2021/05/02.
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

public protocol MutableGraph: Graph {
    /// Create a new mutable graph of the specified kind, with the specified count of vertices and
    /// fully disconnected.
    ///
    /// - Parameter kind:   A `GraphConnections` value specifying the type of connection
    ///                     between vertices the new mutable graph instance will hold.
    /// - Parameter vertexCount:    An `Int` value specifying the number of vertices the new
    ///                             mutable graph instance will contain.
    ///                             **Must not be negative**.
    /// - Returns:  A new mutable graph, initialized to contain the specified number of vertices,
    ///             adopting the specified type of connection between its vertices, without any
    ///             edge present. That is the returned graph will have its `edgeCount` set to `0`,
    ///             and every vertex in it will have no adjacency set.
    init(kind: GraphConnections, vertexCount: Int)
    
    /// Adds the given edge to this graph, by creating an adjacency between the two vertices
    /// of the edge accordingly to the graph's property `kind` value.
    ///
    /// The given edge must represent a connection between
    /// two vertices contained in the graph `verticies` range, otherwise a runtime error
    /// should occur.
    /// Conforming types must take into account the `kind` value in the implementation of this
    /// method, therefore store the edge, create the adjacency and update
    /// the `edgeCount` property of the graph accordingly to how the edge has to be
    /// interpretated, either as a **direct edge** when graph's `kind` property has a value of `.directed`,
    /// or conversley as an **undirected edge** when `kind` property has a value of `.undirected`.
    ///
    /// In the following example is shown how the method should behave for a graph instance
    /// with its `kind` property value equals to `.directed`:
    ///
    /// ```swift
    /// // supposing `g` is a graph where g.kind == .directed,
    /// // g.vertices = 0..<10, g.edgeCount = 0;
    /// // supposing `e` is an edge where e.tail == 0,
    /// // e.head == 1
    /// g.add(edge: e)
    ///
    /// let tailAdjs = g.adjacencies(vertex: e.tail)
    /// let headAdjs = g.adjancencies(vertex: e.head)
    ///
    /// print(tailAdjs.count)
    /// // prints: "1"
    ///
    /// print(tailAdjs.first.tail)
    /// // prints: "0"
    ///
    /// print(tailAdjs.first.head)
    /// // prints: "1"
    ///
    /// print(headAdjs.isEmpty)
    /// // prints: "true"
    ///
    /// print(g.edgeCount)
    /// // prints: 1
    /// ```
    ///
    /// In the next example is shown instead how the method should work for a graph instance
    /// with its `kind` property value equal to `.undirected`:
    ///
    /// ```swift
    /// // supposing `g` is a graph where g.kind == .undirected,
    /// // g.vertices = 0..<10, g.edgeCount = 0;
    /// // supposing `e` is an edge where e.either == 3,
    /// // e.other(e.either) == 2
    /// g.add(edge: e)
    ///
    /// let vAdjs = g.adjacencies(vertex: e.either)
    /// let wAdjs = g.adjacencies(vertex: e.other(e.either))
    ///
    /// print(vAdjs.count)
    /// // prints: "1"
    ///
    /// print(e <~> vAdjs.first)
    /// // prints: "true"
    ///
    /// print(wAdjs.count)
    /// // print: "1"
    ///
    /// print(e <~> wAdjs.first)
    /// // prints: "true"
    ///
    /// print(g.edgeCount)
    /// // prints: "1"
    /// ```
    ///
    /// - Parameter edge: An edge to add to this graph.
    /// - Precondition: `edge` parameter must have its vertices values included in `vertices`.
    /// - Complexity:   Conforming types are supposed to be O(1).
    ///                 A deviation from such performance **must** be documented since other
    ///                 default implementations and generic graph utilities rely
    ///                 on this method being O(1) complexity.
    mutating func add(edge: Edge)
    
    /// Removes from graph the given edge, when present. Returns `true` if the removal operation
    /// was succesful, otherwise `false`.
    ///
    /// The given edge must represent a connection between two vertices
    /// contained in the graph's `verticies` range otherwise a runtime error should occur.
    /// Conforming types must take into account the `kind` value of the graph in their implementation
    /// of this method, handling the edge as a **direct edge** when such `kind` property has a
    /// value of `.direct`, and conversly as an **undirected edge** when `kind` is set to `.undirected`.
    /// Thus the method should remove the edge from the graph instance stored edges,  remove the adjacency
    /// between the vertices of the edge, and update the instance property `edgeCount` accordingly.
    ///
    /// In the following example is shown how the method should beahve for a graph instance
    /// with its `kind` property value equals to `.directed`:
    ///
    /// ```Swift
    /// // supposing `g` is a graph where g.kind == .directed,
    /// // g.vertices = 0..<10, g.edgeCount = 1,
    /// // g.adjacencies(vertex: 0).first == (tail: 0, head: 1);
    /// // supposing `e` is an edge where e.tail == 0,
    /// // e.head == 1;
    /// let eRev = e.reversed()
    ///
    /// print(g.remove(edge: eRev))
    /// // prints: "false"
    ///
    /// print(g.edgeCount)
    /// // prints: "1"
    ///
    /// print(g.remove(edge: e))
    /// // prints: "true"
    ///
    /// print(g.edgeCount)
    /// // prints: "0"
    ///
    /// print(g.adjancencies(vertex: e.tail))
    /// // prints: "[]"
    /// ```
    ///
    /// Only when passing to the method an edge that effectively represents a direct edge of the adjacency,
    /// the removal takes then effect.
    ///
    /// In the next example is shown instead how the method should behave for a graph instance
    /// with its `kind` property value equals to `.undirected`:
    ///
    /// ```swift
    /// // supposing `g` is a graph where g.kind == .undirected,
    /// // g.vertices = 0..<10, g.edgeCount = 1,
    /// // g.adjacencies(vertex: 2).first == (tail: 2, head: 3),
    /// // g.adjacencies(vertex: 3).first == (tail: 3, head: 2);
    /// // supposing `e` is an edge where e.either == 3,
    /// // e.other(e.either) == 2
    /// print(g.remove(edge: e))
    /// // prints: "true"
    ///
    /// print(g.edgeCount)
    /// // prints: "0"
    ///
    /// print(adjacencies(vertex: e.either))
    /// // prints: "[]"
    ///
    /// print(adjacencies(vertex: e.other(e.either)))
    /// // prints: "[]"
    /// ```
    ///
    /// In this case the edge has been handled as an **undirected edge**, thus the removal
    /// took effect also on the reciprocal adjacency.
    ///
    /// - Parameter edge:   An edge to remove from the graph, must be between two vertices
    ///                     included in the graph `vertices` range.
    /// - Returns: A Bool value, `true` when the removal of the edge performed, false otherwise.
    /// - Precondition: `edge` parameter must have its vertices values included in `vertices`.
    /// - Complexity:   Conforming types are supposed to be O(*M*) where *M*
    ///                  is the number of adjacencies of the verticies in the given edge.
    ///                 A deviation from such performance **must** be documented since other
    ///                 default implementations and generic graph utilities rely
    ///                 on this method performance.
    @discardableResult
    mutating func remove(edge: Edge) -> Bool
    
    /// Calling this method will effectively remove every edge in the graph instance,
    /// making all its vertices disconnected from each other.
    ///
    /// - Complexity: O(1)
    mutating func removeAllEdges()
    
    /// Reverses edges of the graph.
    ///
    /// This method has particular importance for graphs whose `kind` property value is `.directed`
    /// in order to invert a **direct graph**.
    /// Conversely, graphs whose `kind` property value is `.undirected` have their inverted graph
    /// corresponding to the same graph since their vertices' connections are bi-directional.
    /// In the following example is shown the beahvior of this method on a **direct graph**:
    /// ```Swift
    /// // supposing `g` is a graph where g.kind == .directed,
    /// // g.vertices = 0..<10, g.edgeCount = 3,
    /// // g.adjacencies(vertex: 2) == [(tail: 2, head: 5)]
    /// // g.adjacencies(vertex: 3) == [(tail: 3, head: 2)]
    /// // g.adjacencies(vertex: 5) == [(tail: 5, head: 3)]
    /// g.reverse()
    ///
    /// print(g.edgeCount)
    /// // prints: "3"
    ///
    /// print(g.adjacencies(vertex: 2))
    /// // prints: "[(tail: 2, head: 3)]"
    ///
    /// print(g.adjacencies(vertex: 3))
    /// // prints: "[(tail: 3, head: 5)]"
    ///
    /// print(g.adjacencies(vertex: 5))
    /// // prints: "[(tail: 5, head: 2)]"
    /// ```
    ///
    /// - Complexity:   O(*V* + *E*) where *V*  is the count of vertices in the graph,
    ///                 and*E* is the number of edges in the graph.
    mutating func reverse()
    
}
