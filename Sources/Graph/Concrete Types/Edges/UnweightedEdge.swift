//
//  UnweightedEdge.swift
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

/// An unweighted edge of a graph.
public struct UnweightedEdge: GraphEdge, Codable {
    var v: Int
    
    var w: Int
    
    /// Creates a new edge instance connecting the two given vertices.
    ///
    /// - Parameter vertices:   A tuple of two non negative `Int` values representing the two
    ///                         vertices the created edge connects.
    /// - Returns: A new edge representing a connection between the two given vertices in a graph.
    public init(vertices: (Int, Int)) {
        precondition(vertices.0 >= 0 && vertices.1 >= 0, "Vertices must not be negative.")
        
        self.v = vertices.0
        self.w = vertices.1
    }
    
    /// Creates a new edge instance which will have specifically as its `tail` and `head`
    /// vertices values those specified as the parameters `tail` and `head`.
    ///
    /// - Parameter tail: A non negative `Int` value representing the tail vertex of the newly created edge.
    /// - Parameter head: A non negative `Int` value representing the head vertex of the newly created edge.
    /// - Returns:  A new edge instance, which will have specifically as its `tail` and `head`
    ///             vertices values those specified as the parameters `tail` and `head`.
    public init(tail: Int, head: Int) {
        precondition(tail >= 0, "Tail vertex must not be negative.")
        precondition(head >= 0, "Head vertex must not be negative.")
        
        self.v = tail
        self.w = head
    }
    
    public var either: Int {
        get { v }
        set {
            precondition(newValue >= 0, "New vertex value must not be negative.")
            
            v = newValue
        }
    }
    
    public func other(_ vertex: Int) -> Int {
        if vertex == v { return w }
        if vertex == w { return v }
        fatalError("Vertex: \(vertex) is not in edge.")
    }
    
    public func reversed() -> UnweightedEdge {
        UnweightedEdge(tail: w, head: v)
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

