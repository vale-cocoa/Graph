//
//  AnyWeightedGraphEdge.swift
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

/// A type-erased weighted graph edge wrapping any weighted graph edge.
///
/// An `AnyWeightedGraphEdge` instance forwards its operations to a base weighted edge
/// having the same `Weight` type, hiding the specifics of the underalying weighted edge.
public struct AnyWeightedGraphEdge<Weight: AdditiveArithmetic & Comparable & Hashable>: WeightedGraphEdge {
    fileprivate let _box: _Base<Weight>
    
    fileprivate init(_ box: _Base<Weight>) {
        self._box = box
    }
    
    /// Creates a new `AnyWeightedGraphEdge` instance by wrapping the given weighted edge.
    ///
    /// - Parameter concrete: Some `WeightedGraphEdge` instance to wrap.
    /// - Returns:  A new `AnyWeightedGraphEdge` wrapping the given concrete weighted edge instance
    ///             and with its same `Weight` type.
    public init<Concrete: WeightedGraphEdge>(_ concrete: Concrete) where Concrete.Weight == Weight {
        self._box = _Box(concrete)
    }
    
    /// Creates a new `AnyWeightedGraphEdge` instance connecting the two given vertices and having
    /// the specified `weight` value.
    ///
    /// - Parameter vertices:   A tuple of two non negative `Int` values representing the two
    ///                         vertices the created weighted edge connects.
    /// - Parameter weight: A `Weight` value.
    /// - Returns: A new `AnyWeightedGraphEdge` representing a weighted edge connecting
    ///            the two given vertices with the specified `weight` value.
    public init(vertices: (Int, Int), weight: Weight) {
        let edge = WeightedEdge(vertices: vertices, weight: weight)
        self._box = _Box(edge)
    }
    
    /// Creates a new `AnyWeightedGraphEdge` instance which will have specifically as its `tail` and `head`
    /// vertices values those specified as the parameters `tail` and `head`, and the specified `weight` value.
    ///
    /// - Parameter tail:   A non negative `Int` value representing the tail vertex
    ///                     of the newly created weighted edge.
    /// - Parameter head:   A non negative `Int` value representing the head vertex
    ///                     of the newly created weighted edge.
    /// - Parameter weight: A `Weight` value.
    /// - Returns:  A new `AnyWeightedGraphEdge` instance,
    ///             which will have specifically as its `tail` and `head` vertices values
    ///             those specified as the parameters `tail` and `head`, and as `weight`
    ///             value the one specified as `weight` parameter.
    public init(tail: Int, head: Int, weight: Weight) {
        let edge = WeightedEdge(tail: tail, head: head, weight: weight)
        self._box = _Box(edge)
    }
    
    public var either: Int { _box.either }
    
    public func other(_ vertex: Int) -> Int { _box.other(vertex) }
    
    public var weight: Weight { _box.weight }
    
    public func reversed() -> AnyWeightedGraphEdge<Weight> {
        let reversedBox = _box.reversed()
        
        return Self(reversedBox)
    }
    
    public func reversedWith(weight: Weight) -> AnyWeightedGraphEdge<Weight> {
        let reversedBox = _box.reversedWith(weight: weight)
        
        return Self(reversedBox)
    }
    
}

// MARK: - _Base abstract class for type erasure
extension AnyWeightedGraphEdge {
    fileprivate class _Base<T>: WeightedGraphEdge {
        init() {
            guard
                type(of: self) != _Base.self
            else { fatalError("Cannot create instances of AnyWeightedGraphEdge._Base; create a subclass instance instead.") }
        }
        
        var either: Int { fatalError("Must override") }
        
        func other(_ vertex: Int) -> Int { fatalError("Must override") }
        
        var weight: Weight { fatalError("Must override") }
        
        func reversed() -> Self { fatalError("Must override") }
        
        func reversedWith(weight: Weight) -> Self { fatalError("Must override") }
    
    }
    
}

// MARK: - _Box subclass for type erasure
extension AnyWeightedGraphEdge {
    fileprivate final class _Box<Concrete: WeightedGraphEdge>: _Base<Concrete.Weight> where Weight == Concrete.Weight {
        let concrete: Concrete
        
        init(_ concrete: Concrete) { self.concrete = concrete }
        
        override var either: Int { concrete.either }
        
        override func other(_ vertex: Int) -> Int { concrete.other(vertex) }
        
        override var weight: Weight { concrete.weight }
        
        override func reversed() -> Self {
            let reversedConcrete = concrete.reversed()
            
            return Self(reversedConcrete)
        }
        
        override func reversedWith(weight: Weight) -> Self {
            let reversedConcrete = concrete.reversedWith(weight: weight)
            
            return Self(reversedConcrete)
        }
        
    }
    
}

