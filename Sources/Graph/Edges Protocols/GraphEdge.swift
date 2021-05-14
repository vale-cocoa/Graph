//
//  GraphEdge.swift
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

// Operator for "undirected comparison" of two edges.
infix operator <~>

/// An edge in a `Graph`.
public protocol GraphEdge: Hashable {
    /// Returns one of the two vertices connected by this edge.
    ///
    /// - Complexity: O(1).
    var either: Int { get }
    
    /// Returns the other vertex in this edge, connected to the given one.
    ///
    /// `GraphEdge` represents an edge of a graph without differentating if either is a **direct edge** or
    /// an **undirected edge**. In order to do that, it doesn't strongly declares the two vertices connected,
    /// but rather uses this method to obtain the vertex connected to the one given as parameter.
    /// It is always possible to obtain the two vertices connected by and edge instance conforming to
    /// `GraphEdge` by doing:
    ///
    /// ```Swift
    /// // assuming `e` is an instance of type `E`
    /// // where `E: GraphEdge`:
    /// let vertex = e.either
    /// let neighbour = e.other(vertex)
    /// ```
    ///
    /// - Parameter vertex: A vertex of this edge.
    /// - Returns: The other vertex in the edge, connected to the given one.
    /// - Complexity: O(1).
    /// - Warning: Conforming types's behavior of this method for vertices connected by an  instance,
    ///         is expected to be as the one in the following example:
    ///
    /// ```Swift
    /// // assuming `e` is an instance of type `E`
    /// // where `E: GraphEdge`:
    /// let v = e.either
    /// let w = e.other(v)
    /// let u = e.other(w)
    /// u == v // must be true
    /// ```
    ///
    /// When given as `vertex` parameter a value neither equal to `either` value nor the one retunred by
    /// `other(either)`, then conforming types are expected to fail with a runtime error:
    ///
    /// ```Swift
    /// // assuming `e` is an instance of type `E`
    /// // where `E: GraphEdge`,
    /// // `v` == e.ither, `w` == e.other(e.either);
    /// // assuming also `u` is another vertex where
    /// // `u` != `v` and `u` != `w`
    /// // then doing:
    /// let y = e.other(u) // NOT PERMITTED, Runtime error.
    /// ```
    ///
    func other(_ vertex: Int) -> Int
    
    /// Returns a new edge instance with its vertices `either` and `other(either)` values swapped.
    ///
    /// In the following example is shown what is the expected beahvior of this method for a type conforming
    /// to `GraphEdge`:
    ///
    /// ```Swift
    /// // assuming `e` is an instance of type `E`
    /// // where `E: GraphEdge`:
    /// let v = e.either
    /// let w = e.other(v)
    /// let eRev = e.reversed
    /// print(eRev.either == w) // prints: "true"
    /// print(eRev.other(eRevEither) == v) // prints: "true"
    /// ```
    ///
    /// - Returns: A new edge with its vertices swapped.
    /// - Complexity: O(1).
    func reversed() -> Self
    
}

extension GraphEdge {
    /// Returns the same value of `either`. Useful to handle an edge as a **directed edge**.
    ///
    /// - Complexity: O(1).
    @usableFromInline
    var tail: Int { return either }
    
    /// Returns the same value of doing `other(either)`. Useful to handle an edge as a **directed edge**.
    ///
    /// - Complexity: O(1).
    @usableFromInline
    var head: Int { return other(either) }
    
    /// A boolean value: `true` when `either == other(either)` or `false` otherwise.
    ///
    /// - Complexity: O(1).
    @usableFromInline
    var isSelfLoop: Bool { either == other(either) }
    
}

extension GraphEdge {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.either == rhs.either && lhs.other(lhs.either) == rhs.other(rhs.either)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(either)
        hasher.combine(other(either))
    }
    
    /// Operator for comparing edges handled as **undirected edge**.
    ///
    /// The following example shows two edges representing the same **undirected connection**
    /// between two vertices compared using this operator and the classic `==` operator:
    ///
    /// ```Swift
    /// // assuming `e` and `d` are two edges of type `E`
    /// // where `E: GraphEdge`,
    /// // also assuming `e.either == d.other(d.either)`,
    /// // and `e.other(e.either) == d.either`:
    /// print(e == d)
    /// // prints: "false" because `e` and `d`
    /// // have different `either` values
    ///
    /// print(e <=> d)
    /// // prints: "true" because `e.either == d.other(d.either)` and
    /// // e.other(e.either) == d.either
    /// // thus they are the same "undirected edge"
    /// ```
    ///
    /// - Parameter lhs: An edge instance to compare as **undirected edge**.
    /// - Parameter rhs: An edge instance. to compare as **undirected edge**.
    /// - Returns:  A boolean value: `true` if the two edges contain the same vertices,
    ///             regardless of their order as `either` and `other(either)`.
    /// - Complexity: O(1).
    public static func <~> (lhs: Self, rhs: Self) -> Bool {
        guard lhs != rhs else { return true }
        
        return lhs.either == rhs.other(rhs.either) && lhs.other(lhs.either) == rhs.either
    }
    
}

