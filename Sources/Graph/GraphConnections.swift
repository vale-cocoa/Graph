//
//  GraphConnections.swift
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

/// How the vertices are connected in a `Graph`.
@frozen
public enum GraphConnections: CaseIterable {
    /// Vertices in the graph are connected through **directed edges**.
    ///
    /// An edge in this kind of graph is intended as uni-directional, therefore it represents
    /// a connection in the graph from a `source` vertex to a `destination` vertex only:
    /// that is given two vertices `v` and `w` in a **directed graph**, an edge from `v` to `w`
    /// can only  be traversed in that direction.
    /// To also form a connection in the graph going in the opposite direction between the two vertices,
    /// another edge must be added to the graph, expressively going from `w` to `v`.
    case directed
    
    /// Vertices in the graph are connected through **undirected edges**.
    ///
    /// An edge in this kind of graph is intended as bi-directional, therefore it represents
    /// a connection in the graph between two vertices which can be traversed in both directions:
    /// that is given two vertices `v` and `w` in an **undirected graph**, an edge between them
    /// can be traversed from `v` to `w` and from `w` to `v`.
    case undirected
    
}

extension GraphConnections: Codable {
    enum Base: String, Codable {
        case directed
        case undirected
        
        func toGraphConnections() -> GraphConnections {
            switch self {
            case .directed: return .directed
            case .undirected: return .undirected
            }
        }
        
        init(_ kind: GraphConnections) {
            switch kind {
            case .directed: self = .directed
            case .undirected: self = .undirected
            }
        }
        
    }
    
    enum CodingKeys: String, CodingKey {
        case graphConnectionType
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let baseValue = Base(self)
        try container.encode(baseValue, forKey: .graphConnectionType)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let baseValue = try container.decode(Base.self, forKey: .graphConnectionType)
        self = baseValue.toGraphConnections()
    }
    
}
