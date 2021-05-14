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

public struct AnyGraph<Edge: GraphEdge>: Graph {
    private let _box: _Base<Edge>
    
    public init<Concrete: Graph>(_ concrete: Concrete) where Concrete.Edge == Edge {
        self._box = _Box(concrete)
    }
    
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
