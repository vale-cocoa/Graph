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

public struct AnyWeightedGraphEdge<Weight: AdditiveArithmetic & Comparable & Hashable>: WeightedGraphEdge {
    fileprivate let _box: _Base<Weight>
    
    fileprivate init(_ box: _Base<Weight>) {
        self._box = box
    }
    
    public init<Concrete: WeightedGraphEdge>(_ concrete: Concrete) where Concrete.Weight == Weight {
        self._box = _Box(concrete)
    }
    
    public init(vertices: (Int, Int), weight: Weight) {
        let edge = WeightedEdge(vertices: vertices, weight: weight)
        self._box = _Box(edge)
    }
    
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

