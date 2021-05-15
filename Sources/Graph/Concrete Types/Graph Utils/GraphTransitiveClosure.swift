//
//  GraphTransitiveClosure.swift
//  Graph
//
//  Created by Valeriano Della Longa on 2021/05/08.
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

import Foundation

public final class GraphTransitiveClosure<G: Graph> {
    public let graph: G
    
    private let _memoizedVisited = NSCache<NSNumber, NSSet>()
    
    private lazy var _connectedComponents: GraphStronglyConnectedComponents<G> = {
        GraphStronglyConnectedComponents(graph: graph)
    }()
    
    public init(graph: G) {
        self.graph = graph
    }
    
    public func reachability(from source: Int, to destination: Int) -> Bool {
        precondition(0..<graph.vertexCount ~= source, "Vertex: \(source) is not in graph.")
        precondition(0..<graph.vertexCount ~= destination, "Vertex: \(destination) is not in graph.")
        
        guard
            graph.kind == .directed
        else {
            
            return _connectedComponents.areStronglyConnected(source, destination)
        }
        
        if let cached = _memoizedVisited.object(forKey: source as NSNumber) {
            
            return cached.contains(destination)
        }
        
        let visited = graph.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: source, { _ in})
        defer {
            _memoizedVisited.setObject(visited as NSSet, forKey: source as NSNumber)
        }
        
        return visited.contains(destination)
    }
    
}
