//
//  AnyGraph.swift
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

/// A type-erased wrapper over any graph.
///
/// An `AnyGraph` instance forwards its operations to a base graph having the same `Edge` type,
/// hiding the specifics of the underlaying graph.
public struct AnyGraph<Edge: GraphEdge>: Graph {
    private let _box: _Base<Edge>
    
    /// Creates a new `AnyGraph` instance by wrapping the given graph instance.
    ///
    /// - Parameter concrete: Some `Graph` instance to wrap
    /// - Returns:  A new `AnyGraph` instance wrapping the given concrete graph instance,
    ///             with the same `Edge` type of the wrapped concrete graph.
    public init<Concrete: Graph>(_ concrete: Concrete) where Concrete.Edge == Edge {
        self._box = _Box(concrete)
    }
    
    /// Creates a new `AnyGraph` instance with the same specified type of graph connection and
    /// containing the specified edges.
    ///
    /// In the following example is shown the behavior of this initializer, when the `edges` parameter
    /// contains or doesn't contain some edges:
    /// ```Swift
    /// // Assuming edges is a mutable array of edges, which initially contains
    /// // a couple of edges, one connecting vertices 0 and 10, and the other
    /// // the vertices 3 and 14:
    /// var graph = AnyGraph(kind:.directed, edges: edges)
    ///
    /// print(graph.kind)
    /// // prints: ".directed"
    ///
    /// print(graph.vertexCount)
    /// // prints: "15"
    ///
    /// print(graph.edgeCount)
    /// // prints: "2"
    ///
    /// print(graph.adjacencies(vertex: 0))
    /// // prints: "[(0 : 10)]"
    ///
    /// print(graph.adjacencies(vertex: 3))
    /// // prints: "[(3 : 14)]"
    ///
    ///
    /// // Now let's create a new AnyGraph by providing an empty array as edges:
    /// edges.removeAll()
    /// graph = AnyGraph(kind:.directed, edges: edges)
    ///
    /// print(graph.kind)
    /// // prints: ".directed"
    ///
    /// print(graph.vertexCount)
    /// // prints: "0"
    ///
    /// print(graph.edgeCount)
    /// // prints: "0"
    ///
    /// ```
    ///
    /// Depending on the `kind` value passed, edges will be treated accordingly:
    /// ```Swift
    /// // assuming edges is an array of edges, containing a couple of edges,
    /// // one connecting vertices 0 and 10,
    /// // and the other the vertices 3 and 14:
    /// let directedGraph = AnyGraph(kind: .directed, edges: edges)
    ///
    /// print(directedGraph.vertexCount)
    /// // prints: "15"
    ///
    /// print(directedGraph.edgeCount)
    /// // prints: "2"
    ///
    /// // print(directedGraph.adjacencies(vertex: 0))
    /// // prints: "[(0 : 10)]"
    ///
    /// print(directedGraph.adjacencies(vertex: 3))
    /// // prints: "[(3 : 14)]"
    ///
    ///
    /// let undirectedGraph = AnyGraph(kind: .undirected, edges: edges)
    ///
    ///// print(undirectedGraph.vertexCount)
    /// // prints: "15"
    ///
    /// print(undirectedGraph.edgeCount)
    /// // prints: "2"
    ///
    /// print(undirectedGraph.adjacencies(vertex: 0))
    /// // prints: "[(0 : 10]"
    ///
    /// print(undirectedGraph.adjacencies(vertex: 3))
    /// // prints: "[(0 : 10]"
    ///
    /// print(undirectedGraph.adjacencies(vertex: 10))
    /// // prints: "[(10 : 0)]"
    ///
    /// print(undirectedGraph.adjacencies(vertex: 14))
    /// // prints: "[(14 : 3)]"
    /// ```
    ///
    /// - Parameter kind: A `GraphConnections` value.
    /// - Parameter edges:  An array of edges the graph will contain.
    ///                     Note that if the given array is empty, then the returned graph will
    ///                     have its `vertexCount` value seto to `0`.
    ///                     On the other hand, when the given array of edges contains
    ///                     some edges, then the vertices connection they represent
    ///                     will be treated as specified with the `kind` parameter
    ///                     in the process of creating the new graph; its `vertexCount`
    ///                     will be equal to the max vertex value present in those edges + 1.
    /// - Returns:  A new `AnyGraph` instance with the specified type of graph connections
    ///             containing the given edges.
    public init(kind: GraphConnections, edges: [Edge]) {
        let adjacencyList = AdjacencyList(kind: kind, edges: edges)
        self._box = _Box(adjacencyList)
    }
    
    public var kind: GraphConnections { _box.kind }
    
    public var vertexCount: Int { _box.vertexCount }
    
    public var edgeCount: Int { _box.edgeCount }
    
    public func adjacencies(vertex: Int) -> [Edge] {
        _box.adjacencies(vertex: vertex)
    }
    
    public func reversed() -> Self {
        AnyGraph(_box.reversed())
    }
    
}

// MARK: - _Base abstract class for type erasure
extension AnyGraph {
    fileprivate class _Base<T>: Graph {
        init() {
            guard
                type(of: self) != _Base.self
            else { fatalError("Cannot create instances of AnyGraph._Base; create a subclass instance instead.") }
        }
        
        convenience required init(kind: GraphConnections, edges: [Edge]) {
            fatalError("Must override.")
        }
        
        var kind: GraphConnections { fatalError("Must override.") }
        
        var vertexCount: Int { fatalError("Must override.") }
        
        var edgeCount: Int { fatalError("Must override.") }
        
        func adjacencies(vertex: Int) -> [Edge] {
            fatalError("Must override.")
        }
        
        func reversed() -> Self {
            fatalError("Must override.")
        }
        
    }
        
}

// MARK: - _Box subclass for type erasure
extension AnyGraph {
    fileprivate final class _Box<Concrete: Graph>: _Base<Concrete.Edge> where Concrete.Edge == Edge {
        let concrete: Concrete
        
        fileprivate init(_ concrete: Concrete) {
            self.concrete = concrete
        }
        
        convenience required init(kind: GraphConnections, edges: [Edge]) {
            let concrete = Concrete(kind: kind, edges: edges)
            self.init(concrete)
        }
        
        override var kind: GraphConnections { concrete.kind }
        
        override var vertexCount: Int { concrete.vertexCount }
        
        override var edgeCount: Int { concrete.edgeCount }
        
        override func adjacencies(vertex: Int) -> [Edge] {
            concrete.adjacencies(vertex: vertex)
        }
        
        override func reversed() -> Self {
            Self(concrete.reversed())
        }
        
    }
    
}
