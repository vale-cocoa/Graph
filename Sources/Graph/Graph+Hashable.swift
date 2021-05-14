//
//  Graph+Hashable.swift
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

extension Graph {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard
            lhs.kind == rhs.kind,
            lhs.vertexCount == rhs.vertexCount,
            lhs.edgeCount == rhs.edgeCount
        else { return false }
        
        for vertex in 0..<lhs.vertexCount {
            guard lhs.adjacencies(vertex: vertex) == rhs.adjacencies(vertex: vertex)
            
            else { return false }
        }
        
        return true
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(kind)
        hasher.combine(vertexCount)
        hasher.combine(edgeCount)
        for vertex in 0..<vertexCount {
            hasher.combine(adjacencies(vertex: vertex))
        }
    }
    
}

