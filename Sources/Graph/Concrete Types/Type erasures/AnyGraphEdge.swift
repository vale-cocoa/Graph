//
//  AnyGraphEdge.swift
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

public struct AnyGraphEdge: GraphEdge {
    fileprivate let _box: _Base
    
    public init<Concrete: GraphEdge>(_ concrete: Concrete) {
        self._box = _Box(concrete)
    }
    
    public init(vertices: (Int, Int)) {
        let edge = UnweightedEdge(vertices: vertices)
        self._box = _Box(edge)
    }
    
    public init(tail: Int, head: Int) {
        let edge = UnweightedEdge(tail: tail, head: head)
        self._box = _Box(edge)
    }
        
    public var either: Int { _box.either }
    
    public func other(_ vertex: Int) -> Int { _box.other(vertex) }
    
    public func reversed() -> AnyGraphEdge {
        let revBox = _box.reversed()
        
        return AnyGraphEdge(revBox)
    }
    
}

// MARK: - _Base abstract class for type erasure
extension AnyGraphEdge {
    fileprivate class _Base: GraphEdge {
        init() {
            guard
                type(of: self) != _Base.self
            else { fatalError("Cannot create instances of AnyGraphEdge._Base; create a subclass instead.") }
        }
        
        var either: Int { fatalError("Must Override") }
        func other(_ vertex: Int) -> Int { fatalError("Must Override") }
        func reversed() -> Self { fatalError("Must Override") }
    }
    
}

// MARK: _Box subclass for type erasure
extension AnyGraphEdge {
    fileprivate final class _Box<Concrete: GraphEdge>: _Base {
        let concrete: Concrete
        
        init(_ concrete: Concrete) { self.concrete = concrete }
        
        override var either: Int { return concrete.either }
        
        override func other(_ vertex: Int) -> Int { return concrete.other(vertex) }
        
        override func reversed() -> Self { return Self(concrete.reversed()) }
    }
    
}

