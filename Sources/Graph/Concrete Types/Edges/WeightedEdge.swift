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

public struct WeightedEdge<Weight: AdditiveArithmetic & Comparable & Hashable>: WeightedGraphEdge {
    let v: Int
    
    let w: Int
    
    public let weight: Weight
    
    public var either: Int { v }
    
    public init(vertices: (Int, Int), weight: Weight) {
        self.v = vertices.0
        self.w = vertices.1
        self.weight = weight
    }
    
    public init(tail: Int, head: Int, weight: Weight) {
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
    
}

extension WeightedEdge: Codable where Weight: Codable {  }
