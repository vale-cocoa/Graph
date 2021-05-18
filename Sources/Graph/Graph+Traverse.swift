//
//  Graph+Traverse.swift
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

import Deque

/// How to traverse the edges in a `Graph`.
@frozen
public enum GraphTraversal: CaseIterable {
    /// Adopt the **Deep First Search** traversing: keep traversing an adjacent vertices as far as possible,
    /// then get back and traverse the other adjacencies to vertices not yet visited.
    ///
    /// Basically this traversal uses *LIFO* approach to visit adjacencies of a vertex not yet visited,
    /// effectively exploring as deep as possible in the graph sooner.
    case DeepFirstSearch
    
    /// Adopt the **Breadth First Search** traversing: visit first all directly adjacent vertices,
    /// then keep going on adjacencies level that were not yet visited.
    ///
    /// Bascially this traversal type uses a *FIFO* approach to visit adjacencies of a vertex not yet visited,
    /// effectively exploring nearby a vertex in the graph then proceeding to a deeper level.
    case BreadthFirstSearch
    
}

// MARK: - Graph traverse methods
extension Graph {
    /// Executes given `body` closure on every adjacency found while traversing each vertex of the graph,
    /// adopting the given graph traversal methodology.
    ///
    /// - Parameter traversal:  A `GraphTraversal` value representing the graph search
    ///                         methodology to adopt.
    /// - Parameter body:   A closure executed when an adjacency not yet visited is found for
    ///                     the vertex currently being visited during the traversal.
    ///                     **Does not execute for parallel edges nor for edges expressing a self cycle**.
    ///                     **Does not execute when the vertex being visited has no adjacencies to a different vertex not yet being visited**.
    /// - Parameter visitedVertex: An `Int` value representing the vertex currently being visited
    ///                             by the traversal.
    /// - Parameter adjacency:  An `Edge` representing an adjacency found for the currently visited vertex,
    ///                         pointing to a vertex not yet been visited.
    /// - Complexity:   O(*V* + *E*) where *V* is the number of vertices in the graph,
    ///                 and *E* is the number of edges in the graph.
    public func visitEveryVertexAdjacency(adopting traversal: GraphTraversal, _ body: (_ visitedVertex: Int, _ adjacency: Edge) throws -> Void) rethrows {
        guard vertexCount > 0 else { return }
        
        var visited = Set<Int>()
        for vertex in 0..<vertexCount where !visited.contains(vertex) {
            if traversal == .DeepFirstSearch {
                try recursiveDFS(reachableFrom: vertex, visited: &visited, body)
            } else {
                try iterativeBFS(reachableFrom: vertex, visited: &visited, body)
            }
        }
    }
    
    /// Executes given `body` closure on every edge representing an adjacency found
    /// while traversing the graph adopting the given `traversal` methdology,
    /// starting from the given `source` vertex, and finally returnig a set containing every
    /// vertex visited during the traversal (`source` included).
    ///
    /// - Parameter traversal:  A `GraphTraversal` value representing the graph search
    ///                         methodology to adopt.
    /// - Parameter source: The vertex of the graph to start from.
    /// - Parameter body:   A closure executed when an adjacency not yet visited is found for
    ///                     the vertex currently being visited during the traversal.
    ///                     **Does not execute for parallel edges nor for edges expressing a self cycle**.
    ///                     **Does not execute when the vertex being visited has no adjacencies to a different vertex not yet being visited**.
    /// - Parameter visitedVertex: An `Int` value representing the vertex currently being visited
    ///                             by the traversal.
    /// - Parameter adjacency:  An `Edge` representing an adjacency found for the currently visited vertex,
    ///                         pointing to a vertex not yet been visited.
    /// - Returns:  A set containing all vertices visited during the graph traversal,
    ///             including the given `source` vertex.
    /// - Complexity:   O(*V* + *E*) where *V* is the number of vertices in the graph,
    ///                 and *E* is the number of edges in the graph.
    /// - Precondition: `source` parameter's value must be included in `0..<vertexCount` range.
    @discardableResult
    public func visitedVertices(adopting traversal: GraphTraversal, reachableFrom source: Int, _ body: (_ visitedVertex: Int, _ adjacency: Edge) throws -> Void) rethrows -> Set<Int> {
        precondition(0..<vertexCount ~= source, "Vertex: \(source) is not included in graph.")
        
        var visited = Set<Int>()
        if traversal == .DeepFirstSearch {
            try recursiveDFS(reachableFrom: source, visited: &visited, body)
        } else {
            try iterativeBFS(reachableFrom: source, visited: &visited, body)
        }
        
        return visited
    }
    
    /// Traverse the graph adopting the given `traversal` methodology, executing the
    /// given `body` closure on each vertex.
    ///
    /// - Parameters:
    ///   - traversal:  A `GraphTraversal` value representing
    ///                 the graph search methodology to adopt.
    ///   - body: A closure executed when a not yet visited vertex is being visited by the traversal.
    ///   - visitedVertex: An `Int` value representing the vertex currently being visited
    ///                     by the traversal.
    /// - Complexity:   O(*V* + *E*) where *V* is the number of vertices in the graph,
    ///                 and *E* is the number of edges in the graph.
    /// - Note: This method visits once each vertex in the graph, even those disconnected from the others.
    public func visitAllVertices(adopting traversal: GraphTraversal, _ body: (_ visitedVertex: Int) throws -> Void) rethrows {
        guard vertexCount > 0 else { return }
        
        var visited = Set<Int>()
        for vertex in 0..<vertexCount where !visited.contains(vertex) {
            if traversal == .DeepFirstSearch {
                try recursiveDFS(reachableFrom: vertex, visited: &visited, body)
            } else {
                try iterativeBFS(reachableFrom: vertex, visited: &visited, body)
            }
        }
    }
    
    /// Traverses the graph adopting the given `traverse` methodology,
    /// starting from the given `source`vertex  and executing the given `body` closure
    /// on each vertex found (including `source`), finally returning a set containing all vertices visited.
    ///
    /// - Parameters:
    ///   - traversal:  A `GraphTraversal` value representing
    ///                 the graph search methodology to adopt.
    ///   - source: A vertex to start from.
    ///   - body: A closure executed when a not yet visited vertex is being visited by the traversal.
    ///   - visitedVertex: An `Int` value representing the vertex currently being visited
    ///                     by the traversal.
    /// - Returns: A set containing all vertices visited during the traversal, including the given `source` one.
    /// - Precondition: `source` parameter must be a value in `0..<vertexCount` range.
    /// - Complexity:   O(*V* + *E*) where *V* is the number of vertices in the graph,
    ///                 and *E* is the number of edges in the graph.
    /// - Warning: Vertices in graph not reachable from the given `source` one are not visited.
    @discardableResult
    public func visitedVertices(adopting traversal: GraphTraversal, reachableFrom source: Int, _ body: (_ visitedVertex: Int) throws -> Void) rethrows -> Set<Int> {
        var visited = Set<Int>()
        if traversal == .DeepFirstSearch {
            try recursiveDFS(reachableFrom: source, visited: &visited, body)
        } else {
            try iterativeBFS(reachableFrom: source, visited: &visited, body)
        }
        
        return visited
    }
    
    /// Traverses every vertex of the graph, reaching also disconnected ones, adopting
    /// the *Deep First Search* approach recursively, executing the given closures.
    ///
    ///
    /// - Parameter preOrderVertexVisit:    A closure executed **before** the traversal proceeds on
    ///                                     checking the adjacencies of the currently visited vertex.
    /// - Parameter visitedVertex: An `Int` value representing the vertex currently being visited
    ///                             by the traversal.
    /// - Parameter visitingVertexAdjacency:    A closure being executed when an adjacency
    ///                                         is found for the vertex being currently visited.
    /// - Parameter visitedVertex: An `Int` value representing the vertex currently being visited
    ///                             by the traversal.
    /// - Parameter adjacency:  An `Edge` representing an adjacency found for the currently visited vertex.
    /// - Parameter hasBeenVisited: A `Bool` value, `true` when the adjacencent vertex in the edge
    ///                             has been already visited, otherwise `false` when it has been just
    ///                             discovered.
    /// - Parameter postOrderVertexVisit:   A closure executed **after** the traversal had checked
    ///                                     the adjacencies of the visited vertex —thus also executed
    ///                                     after having visited recursively those not yet
    ///                                     visited.
    /// - Parameter visitedVertex: An `Int` value representing the vertex currently being visited
    ///                             by the traversal.
    public func depthFirstSearch(preOrderVertexVisit: (_ visitedVertex: Int) throws -> Void, visitingVertexAdjacency: (_ visitedVertex: Int, _ adjacency: Edge, _ hasBeenVisited: Bool) throws -> Void, postOrderVertexVisit: (_ visitedVertex: Int) throws -> Void) rethrows {
        guard vertexCount > 0 else { return }
        
        var visited: Set<Int> = []
        for vertex in 0..<vertexCount where !visited.contains(vertex) {
            try recursiveDFS(reachableFrom: vertex, visited: &visited, preOrderVertexVisit: preOrderVertexVisit, visitingVertexAdjacency: visitingVertexAdjacency, postOrderVertexVisit: postOrderVertexVisit)
        }
    }
    
    /// Traverses every vertex of the graph, reaching also disconnected ones, adopting
    /// the *Breadth First Search* approach, executing the given closures.
    ///
    ///
    /// - Parameter preOrderVertexVisit:    A closure executed **before** the traversal proceeds on
    ///                                     checking the adjacencies of the currently visited vertex.
    /// - Parameter visitedVertex: An `Int` value representing the vertex currently being visited
    ///                             by the traversal.
    /// - Parameter visitingVertexAdjacency:    A closure being executed when an adjacency
    ///                                         is found for the vertex being currently visited.
    /// - Parameter visitedVertex: An `Int` value representing the vertex currently being visited
    ///                             by the traversal.
    /// - Parameter adjacency:  An `Edge` representing an adjacency found for the currently visited vertex.
    /// - Parameter hasBeenVisited: A `Bool` value, `true` when the adjacencent vertex in the edge
    ///                             has been already visited, otherwise `false` when it has been just
    ///                             discovered.
    /// - Parameter postOrderVertexVisit:   A closure executed **after** the traversal had checked
    ///                                     the adjacencies of the visited vertex.
    /// - Parameter visitedVertex: An `Int` value representing the vertex currently being visited
    ///                             by the traversal.
    public func breadthFirstSearch(preOrderVertexVisit: (_ visitedVertex: Int) throws -> Void, visitingVertexAdjacency: (_ visitedVertex: Int, _ adjacency: Edge, _ hasBeenVisited: Bool) throws -> Void, postOrderVertexVisit: (_ visitedVertex: Int) throws -> Void) rethrows {
        guard vertexCount > 0 else { return }
        
        var visited = Set<Int>()
        for vertex in 0..<vertexCount where visited.insert(vertex).inserted {
            var queue: Deque<Int> = [vertex]
            while let source = queue.dequeue() {
                try preOrderVertexVisit(source)
                for edge in adjacencies(vertex: source) {
                    let other = edge.other(source)
                    let hasBeenVisited = !visited.insert(other).inserted
                    try visitingVertexAdjacency(source, edge, hasBeenVisited)
                    if !hasBeenVisited { queue.enqueue(other) }
                }
                try postOrderVertexVisit(source)
            }
        }
    }
    
    /// Traverses the graph starting from the given source vertex, adopting the specified type of traversal,
    /// executes the given body closure on edges leading to adjacencies for every vertex visited,
    /// and then returns a set of visited vertices during such traversal.
    /// The traversal stops as soon as the `stop` inout parameter of body closure is set to `true`,
    /// or when every reachable vertex in the graph starting from the given source vertex has been visited.
    ///
    /// - Parameter traversal: A `GraphTraversal` value, specifying the type of graph traversal to adopt.
    /// - Parameter source: A vertex on the graph from which the traversal starts.
    ///                     **Must be included in the graph**.
    /// - Parameter body:   A closure that gets executed every time an edge leading to an adjacency in graph
    ///                     is enumerated for the vertex actually being visited by the traversal.
    /// - Parameter stop:   An `inout` boolean value that can be set to `true` in the given body closure to
    ///                     halt prematurely the traversal.
    /// - Parameter visitedVertex: The vertex being visited.
    /// - Parameter adjacency: An edge leading to an adjacency of the vertex being visited.
    /// - Parameter hasBeenVisited: A boolean value, `true` when the edge
    ///                             passed as `adjacency` parameter to the closure leads
    ///                             from the visited vertex to an adjacencent vertex already been
    ///                             visited during the traversal.
    /// - Precondition: `source` parameter must be a value in `0..<vertexCount` range.
    /// - Returns: A set including all vertices that have been visited during the traversal.
    /// - Complexity:   O(*V* + *E*), where *V* are the number of vertices included in the graph, and
    ///                 *E* is the count of edges of the graph.
    /// - Warning: Vertices in graph not reachable from the given `source` one are not visited.
    /// - Note: This traversal method will enumerate every edge of visited vertices executing the body
    ///         closure each time a new one is found, including edges representing self-loops or parallel connections.
    /// - Important:    A vertex is included in the returned set —hence marked as visited—
    ///                 as soon as it is discovered by the traversal.
    ///                 Moreover the given source vertex always appears inside the returned set.
    @discardableResult
    public func visitedVertices(adopting traversal: GraphTraversal, reachableFrom source: Int, _ body: (_ stop: inout Bool, _ visitedVertex: Int, _ adjacency: Edge, _ hasBeenVisited: Bool) throws -> Void) rethrows -> Set<Int> {
        precondition(0..<vertexCount ~= source, "Vertex: \(source) is not included in graph.")
        
        var visited: Set<Int> = []
        switch traversal {
        case .DeepFirstSearch:
            try recursiveDFS(reachableFrom: source, visited: &visited, body)
        case .BreadthFirstSearch:
            try iterativeBFS(reachableFrom: source, visited: &visited, body)
        }
        
        return visited
    }
    
}

// MARK: - Helpers for graph traverse methods
extension Graph {
    // MARK: - DFS
    func recursiveDFS(reachableFrom source: Int, visited: inout Set<Int>, _ body: (Int, Edge) throws -> Void) rethrows {
        visited.insert(source)
        for edge in adjacencies(vertex: source) {
            let other = edge.other(source)
            guard visited.insert(other).inserted else { continue }
            
            try body(source, edge)
            try recursiveDFS(reachableFrom: other, visited: &visited, body)
        }
    }
    
    func recursiveDFS(reachableFrom source: Int, visited: inout Set<Int>, _ body: (Int) throws -> Void) rethrows {
        if visited.insert(source).inserted {
            try body(source)
        }
        for edge in adjacencies(vertex: source) {
            let other = edge.other(source)
            if !visited.contains(other) {
                try recursiveDFS(reachableFrom: other, visited: &visited, body)
            }
        }
    }
    
    func recursiveDFS(reachableFrom vertex: Int, visited: inout Set<Int>, preOrderVertexVisit: (Int) throws -> Void, visitingVertexAdjacency: (Int, Edge, Bool) throws -> Void, postOrderVertexVisit: (Int) throws -> Void) rethrows {
        visited.insert(vertex)
        try preOrderVertexVisit(vertex)
        for edge in adjacencies(vertex: vertex) {
            let other = edge.other(vertex)
            let hasBeenVisited = visited.insert(other).inserted == false
            try visitingVertexAdjacency(vertex, edge, hasBeenVisited)
            guard !hasBeenVisited else { continue }
            
            try recursiveDFS(reachableFrom: other, visited: &visited, preOrderVertexVisit: preOrderVertexVisit, visitingVertexAdjacency: visitingVertexAdjacency, postOrderVertexVisit: postOrderVertexVisit)
        }
        try postOrderVertexVisit(vertex)
    }
    
    func recursiveDFS(reachableFrom vertex: Int, visited: inout Set<Int>, _ body: (inout Bool, Int, Edge, Bool) throws -> Void) rethrows {
        visited.insert(vertex)
        
        var stop = false
        for edge in adjacencies(vertex: vertex) {
            let other = edge.other(vertex)
            let hasBeenVisited = !visited.insert(other).inserted
            try body(&stop, vertex, edge, hasBeenVisited)
            guard stop == false else { return }
            
            guard !hasBeenVisited else { continue }
            
            try recursiveDFS(reachableFrom: other, visited: &visited, body)
            guard stop == false else { return }
        }
    }
    
    // MARK: - BFS
    func iterativeBFS(reachableFrom source: Int, visited: inout Set<Int>, _ body: (Int, Edge) throws -> Void) rethrows {
        visited.insert(source)
        var deque: Deque<Int> = [source]
        while let vertex = deque.dequeue() {
            for edge in adjacencies(vertex: vertex) {
                let other = edge.other(vertex)
                if visited.insert(other).inserted {
                    try body(vertex, edge)
                    deque.enqueue(other)
                }
            }
        }
    }
    
    func iterativeBFS(reachableFrom source: Int, visited: inout Set<Int>, _ body: (Int) throws -> Void) rethrows {
        var deque: Deque<Int> = [source]
        while let vertex = deque.dequeue() {
            if visited.insert(vertex).inserted {
                try body(vertex)
            }
            Inner: for edge in adjacencies(vertex: vertex) {
                let other = edge.other(vertex)
                guard !visited.contains(other) else { continue Inner }
                
                deque.enqueue(other)
            }
        }
    }
    
    func iterativeBFS(reachableFrom source: Int, visited: inout Set<Int>, _ body: (inout Bool, Int, Edge, Bool) throws-> Void) rethrows {
        guard visited.insert(source).inserted else { return }
        
        var deque: Deque<Int> = [source]
        var stop = false
        OuterLoop: while let vertex = deque.dequeue() {
            InnerLoop: for edge in adjacencies(vertex: vertex) {
                let other = edge.other(vertex)
                let hasBeenVisited = !visited.insert(other).inserted
                try body(&stop, vertex, edge, hasBeenVisited)
                guard stop == false else { break OuterLoop }
                
                guard !hasBeenVisited else { continue InnerLoop }
                
                deque.enqueue(other)
            }
        }
    }
    
}

// MARK: - GraphTraversal Codable conformance
extension GraphTraversal: Codable {
    enum Base: String, Codable {
        case DeepFirstSearch
        case BreadthFirstSearch
        
        func toGraphTraversal() -> GraphTraversal {
            switch self {
            case .DeepFirstSearch: return .DeepFirstSearch
            case .BreadthFirstSearch: return .BreadthFirstSearch
            }
        }
        
        init(_ traversal: GraphTraversal) {
            switch traversal {
            case .DeepFirstSearch: self = .DeepFirstSearch
            case .BreadthFirstSearch: self = .BreadthFirstSearch
            }
        }
        
    }
    
    enum CodingKeys: String, CodingKey {
        case graphTraversalStrategy
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let baseValue = Base(self)
        try container.encode(baseValue, forKey: .graphTraversalStrategy)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let baseValue = try container.decode(Base.self, forKey: .graphTraversalStrategy)
        self = baseValue.toGraphTraversal()
    }
    
}
