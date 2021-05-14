//
//  WeightedGraphEdge.swift
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

// Operator for "undirected comparison" of two weighted edges.
infix operator <=~=>

/// A weighted edge in a `Graph`, generic over a `Weight` type conforming to `AdditiveArithmetic`,
/// `Comparable`and `Hashable`.
public protocol WeightedGraphEdge: GraphEdge {
    /// The type used as weight for this `WeightedGraphEdge` conforming type.
    associatedtype Weight: AdditiveArithmetic & Comparable & Hashable
    
    /// Returns a `Weight` value, that is the *weight* or *cost* of the connection between
    /// the two vertices of this weighted edge.
    ///
    /// - Complexity: O(1).
    var weight: Weight { get }
    
    /// Returns a new weighted edge instance with its vertices `either` and `other(either)`
    /// values swapped, but with a new `weight` value equals to the the given one.
    ///
    /// In the following example is shown what is the expected beahvior of this method for a type conforming
    /// to `WeightedGraphEdge`:
    ///
    /// ```Swift
    /// // assuming `e` is an instance of type `E`
    /// // where `E: WeightedGraphEdge<Double>`:
    /// let v = e.either
    /// let w = e.other(v)
    /// let doubledWeight = e.weight * 2
    /// let eRev = e.reversedWith(weight: doubleWeight)
    /// print(eRev.either == w) // prints: "true"
    /// print(eRev.other(eRevEither) == v) // prints: "true"
    /// print(eRev.weight == doubleWeight) // prints: "true"
    /// print(eRev.weight == e.weight) // prints: "false"
    /// ```
    ///
    /// Conversely having used the `reversed()` method in the previous example,
    /// would have returned the weighted edge just with its vertices swapped but with the same `weight` value:
    ///
    /// ```Swift
    /// // assuming `e` is an instance of type `E`
    /// // where `E: WeightedGraphEdge<Double>`:
    /// let v = e.either
    /// let w = e.other(v)
    /// let eRev = e.reversed()
    /// print(eRev.either == w) // prints: "true"
    /// print(eRev.other(eRevEither) == v) // prints: "true"
    /// print(eRev.weight == e.weight) // prints: "true"
    /// ```
    /// - Parameter weight: The new `weight` value of the returnedweighted  edge with reversed vertices.
    /// - Returns:  A new weighted edge with its vertices swapped, but with a new `weight` value
    ///             equal the one given as parameter.
    /// - Complexity: O(1).
    func reversedWith(weight: Weight) -> Self
    
}

extension WeightedGraphEdge {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.tail == rhs.tail && lhs.head == rhs.head && lhs.weight == rhs.weight
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(tail)
        hasher.combine(head)
        hasher.combine(weight)
    }
    
    /// Operator for comparing weighted edges handling them as **undirected edge**.
    ///
    /// The following example shows two weighted edges having the same `weight` value and
    /// representing the same **undirected connection** between two vertices compared
    /// using this operator, `GraphEdge`'s `<~>` operator, and the classic `==` operator:
    ///
    /// ```Swift
    /// // assuming `e` and `d` are two edges of type `E`
    /// // where `E: WeightedGraphEdge<Double>`;
    /// // also assuming `e.weight == d.weight`,
    /// // `e.either == d.other(d.either)`,
    /// // and `e.other(e.either) == d.either`:
    /// print(e == d)
    /// // prints: "false"
    ///
    /// print(e <~> d)
    /// // prints: "true"
    ///
    /// print(e <=~=> d)
    /// // prints: "true" because `e` and `d`
    /// // are the same "undirected edge" and
    /// // they also have the same `weight` value
    ///
    /// let z = e.reversedWith(weight: e.wight * 2)
    /// print(e == z)
    /// // prints: "false"
    ///
    /// print(e <~> z)
    /// // prints: "true" because `e` and `z`
    /// // are the same "undirected edge"
    ///
    /// print(e <=~=> z)
    /// // prints: "false" because despite `e` and `z`
    /// // are the same "undirected edge" they have
    /// // different `weight` values.
    /// ```
    ///
    /// - Parameter lhs: A weighted edge instance to compare as **undirected weighted edge**.
    /// - Parameter rhs: A weighted edge instance to compare as **undirected weighted edge**.
    /// - Returns:  A boolean value: `true` if the two weighted edges have the same `weight value`
    ///             and also contain the same vertices, regardless of their order as `either`
    ///             and `other(either)`.
    /// - Complexity: O(1).
    public static func <=~=>(lhs: Self, rhs: Self) -> Bool {
        guard lhs <~> rhs else { return false }
        
        return lhs.weight == rhs.weight
    }
    
}
