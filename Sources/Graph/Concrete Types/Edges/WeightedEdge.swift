//
//  WeightedEdge.swift
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

/// A weighted edge of a graph, generic over the `Weight` type.
public struct WeightedEdge<Weight: AdditiveArithmetic & Comparable & Hashable>: WeightedGraphEdge {
    var v: Int
    
    var w: Int
    
    public var weight: Weight
    
    public var either: Int {
        get { v }
        set {
            precondition(newValue >= 0, "New vertex value must not be negative.")
            
            v = newValue
        }
    }
    
    /// Creates a new weighted edge instance connecting the two given vertices and having
    /// the specified `weight` value.
    ///
    /// - Parameter vertices:   A tuple of two non negative `Int` values representing the two
    ///                         vertices the created weighted edge connects.
    /// - Parameter weight: A `Weight` value.
    /// - Returns: A new weighted edge representing a weighted connection between
    ///            the two given vertices in the graph, with the specified `weight` value.
    public init(vertices: (Int, Int), weight: Weight) {
        precondition(vertices.0 >= 0 && vertices.1 >= 0, "Vertices must not be negative.")
        
        self.v = vertices.0
        self.w = vertices.1
        self.weight = weight
    }
    
    /// Creates a new weighted edge instance which will have specifically as its `tail` and `head`
    /// vertices values those specified as the parameters `tail` and `head`, and the specified `weight` value.
    ///
    /// - Parameter tail:   A non negative `Int` value representing the tail vertex
    ///                     of the newly created weighted edge.
    /// - Parameter head:   A non negative `Int` value representing the head vertex
    ///                     of the newly created weighted edge.
    /// - Parameter weight: A `Weight` value.
    /// - Returns:  A new weighted edge instance,
    ///             which will have specifically as its `tail` and `head` vertices values
    ///             those specified as the parameters `tail` and `head`, and as `weight`
    ///             value the one specified as `weight` parameter.
    public init(tail: Int, head: Int, weight: Weight) {
        precondition(tail >= 0, "Tail vertex must not be negative.")
        precondition(head >= 0, "Head vertex must not be negative.")
        
        self.v = tail
        self.w = head
        self.weight = weight
    }
    
    public func other(_ vertex: Int) -> Int {
        if vertex == v { return w }
        if vertex == w { return v }
        fatalError("Vertex: \(vertex) is not in edge.")
    }
    
    public func reversed() -> WeightedEdge<Weight> {
        WeightedEdge(tail: w, head: v, weight: weight)
    }
    
    public func reversedWith(weight: Weight) -> WeightedEdge<Weight> {
        WeightedEdge(tail: w, head: v, weight: weight)
    }
    
    /// Set the vertex connected in the edge by the given one to the specified new value.
    ///
    /// - Parameter vertex: A vertex in this edge.
    /// - Parameter newValue:   The new vertex connected to the given one in this edge.
    ///                         **Must not be negative**.
    public mutating func setOther(_ vertex: Int, to newValue: Int) {
        precondition(newValue >= 0, "New vertex value must not be negative.")
        
        if vertex == v {
            w = newValue
        }
        else if vertex == w {
            v = newValue
        } else {
            fatalError("Vertex: \(vertex) is not in edge.")
        }
    }
    
    /// Sets the tail vertex of this edge to the specified one.
    ///
    /// - Parameter newValue:   The new value of the tail vertex of this edge.
    ///                         **Must not be negative**
    public mutating func setTail(_ newValue: Int) {
        precondition(newValue >= 0, "New tail vertex value must not be negative.")
        
        v = newValue
    }
    
    /// Sets the head vertex of this edge to the specified one.
    ///
    /// - Parameter newValue:   The new value of the head vertex of this edge.
    ///                         **Must not be negative**
    public mutating func setHead(_ newValue: Int) {
        precondition(newValue >= 0, "New head vertex value must not be negative.")
        
        w = newValue
    }
    
}

extension WeightedEdge: Codable where Weight: Codable {  }
