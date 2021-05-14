//
//  GraphPathsTests.swift
//  GraphTests
//
//  Created by Valeriano Della Longa on 2021/05/14.
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

import XCTest
@testable import Graph

final class GraphPathsTests: XCTestCase {
    var sut: GraphPaths<AdjacencyList<WeightedEdge<Double>>>!
    
    override func setUp() {
        super.setUp()
        
        let graph = givenGraphWithNoEdges(kind: GraphConnections.allCases.randomElement()!)
        let source = Int.random(in: 0..<graph.vertexCount)
        let traversal = GraphTraversal.allCases.randomElement()!
        sut = GraphPaths(graph: graph, source: source, buildPathsAdopting: traversal)
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - Given
    func givenGraphWithNoEdges(kind: GraphConnections) -> AdjacencyList<WeightedEdge<Double>> {
        let vertexCount = Int.random(in: 10..<100)
        
        return AdjacencyList<WeightedEdge<Double>>(kind: kind, vertexCount: vertexCount)
    }
    
    func givenGraphWithEdges(kind: GraphConnections) -> AdjacencyList<WeightedEdge<Double>> {
        let edges = givenRandomWeightedEdges()
        
        return AdjacencyList(kind: kind, edges: edges)
    }
    
    // MARK: - Tests
    func testInitGraphSourceBuildPathsAdopting() {
        let graph = givenGraphWithEdges(kind: GraphConnections.allCases.randomElement()!)
        let source = Int.random(in: 0..<graph.vertexCount)
        let traversal = GraphTraversal.allCases.randomElement()!
        sut = GraphPaths(graph: graph, source: source, buildPathsAdopting: traversal)
        XCTAssertEqual(sut.graph, graph)
        XCTAssertEqual(sut.source, source)
        XCTAssertEqual(sut.traversal, traversal)
    }
    
    // MARK: - hasPath(to:) tests
    func testHasPathTo_whenGraphHasNoEdges() {
        var graph = givenGraphWithNoEdges(kind: .directed)
        var source = Int.random(in: 0..<graph.vertexCount)
        sut = GraphPaths(graph: graph, source: source, buildPathsAdopting: .DeepFirstSearch)
        XCTAssertTrue(sut.hasPath(to: source))
        for destination in 0..<graph.vertexCount where destination != source {
            XCTAssertFalse(sut.hasPath(to: destination))
        }
        
        sut = GraphPaths(graph: graph, source: source, buildPathsAdopting: .BreadthFirstSearch)
        XCTAssertTrue(sut.hasPath(to: source))
        for destination in 0..<graph.vertexCount where destination != source {
            XCTAssertFalse(sut.hasPath(to: destination))
        }
        
        graph = givenGraphWithNoEdges(kind: .undirected)
        source = Int.random(in: 0..<graph.vertexCount)
        sut = GraphPaths(graph: graph, source: source, buildPathsAdopting: .DeepFirstSearch)
        XCTAssertTrue(sut.hasPath(to: source))
        for destination in 0..<graph.vertexCount where destination != source {
            XCTAssertFalse(sut.hasPath(to: destination))
        }
        
        sut = GraphPaths(graph: graph, source: source, buildPathsAdopting: .BreadthFirstSearch)
        XCTAssertTrue(sut.hasPath(to: source))
        for destination in 0..<graph.vertexCount where destination != source {
            XCTAssertFalse(sut.hasPath(to: destination))
        }
    }
    
    func testHasPathTo_whenGraphHasEdges() {
        var graph = givenGraphWithNoEdges(kind: .directed)
        for source in 0..<graph.vertexCount {
            sut = GraphPaths(graph: graph, source: source, buildPathsAdopting: .DeepFirstSearch)
            var visited = sut.graph.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: source, {_ in })
            for destination in 0..<graph.vertexCount {
                if visited.contains(destination) {
                    XCTAssertTrue(sut.hasPath(to: destination))
                } else {
                    XCTAssertFalse(sut.hasPath(to: destination))
                }
            }
            
            sut = GraphPaths(graph: graph, source: source, buildPathsAdopting: .BreadthFirstSearch)
            visited = sut.graph.visitedVertices(adopting: .BreadthFirstSearch, reachableFrom: source, { _ in })
            for destination in 0..<graph.vertexCount {
                if visited.contains(destination) {
                    XCTAssertTrue(sut.hasPath(to: destination))
                } else {
                    XCTAssertFalse(sut.hasPath(to: destination))
                }
            }
        }
        
        graph = givenGraphWithNoEdges(kind: .undirected)
        for source in 0..<graph.vertexCount {
            sut = GraphPaths(graph: graph, source: source, buildPathsAdopting: .DeepFirstSearch)
            var visited = sut.graph.visitedVertices(adopting: .DeepFirstSearch, reachableFrom: source, {_ in })
            for destination in 0..<graph.vertexCount {
                if visited.contains(destination) {
                    XCTAssertTrue(sut.hasPath(to: destination))
                } else {
                    XCTAssertFalse(sut.hasPath(to: destination))
                }
            }
            
            sut = GraphPaths(graph: graph, source: source, buildPathsAdopting: .BreadthFirstSearch)
            visited = sut.graph.visitedVertices(adopting: .BreadthFirstSearch, reachableFrom: source, { _ in })
            for destination in 0..<graph.vertexCount {
                if visited.contains(destination) {
                    XCTAssertTrue(sut.hasPath(to: destination))
                } else {
                    XCTAssertFalse(sut.hasPath(to: destination))
                }
            }
        }
    }
    
    // MARK: - pathFromSource(to:) tests
    func testPathFromSourceTo_whenGraphHasNoEdges() {
        var graph = givenGraphWithNoEdges(kind: .directed)
        for source in 0..<graph.vertexCount {
            sut = GraphPaths(graph: graph, source: source, buildPathsAdopting: .DeepFirstSearch)
            var path = sut.pathFromSource(to: source)
            XCTAssertEqual(path.count, 1)
            XCTAssertEqual(path.first, source)
            for destination in 0..<graph.vertexCount where destination != source{
                path = sut.pathFromSource(to: destination)
                XCTAssertTrue(path.isEmpty)
            }
            
            sut = GraphPaths(graph: graph, source: source, buildPathsAdopting: .BreadthFirstSearch)
            path = sut.pathFromSource(to: source)
            XCTAssertEqual(path.count, 1)
            XCTAssertEqual(path.first, source)
            for destination in 0..<graph.vertexCount where destination != source{
                path = sut.pathFromSource(to: destination)
                XCTAssertTrue(path.isEmpty)
            }
        }
        
        graph = givenGraphWithNoEdges(kind: .undirected)
        for source in 0..<graph.vertexCount {
            sut = GraphPaths(graph: graph, source: source, buildPathsAdopting: .DeepFirstSearch)
            var path = sut.pathFromSource(to: source)
            XCTAssertEqual(path.count, 1)
            XCTAssertEqual(path.first, source)
            for destination in 0..<graph.vertexCount where destination != source {
                path = sut.pathFromSource(to: destination)
                XCTAssertTrue(path.isEmpty)
            }
            
            sut = GraphPaths(graph: graph, source: source, buildPathsAdopting: .BreadthFirstSearch)
            path = sut.pathFromSource(to: source)
            XCTAssertEqual(path.count, 1)
            XCTAssertEqual(path.first, source)
            for destination in 0..<graph.vertexCount where destination != source {
                path = sut.pathFromSource(to: destination)
                XCTAssertTrue(path.isEmpty)
            }
        }
    }
    
    func testPathFromSourceTo_whenGraphHasEdges() {
        var graph = givenGraphWithEdges(kind: .directed)
        for source in 0..<graph.vertexCount {
            sut = GraphPaths(graph: graph, source: source, buildPathsAdopting: .DeepFirstSearch)
            var path = sut.pathFromSource(to: source)
            XCTAssertEqual(path.count, 1)
            XCTAssertEqual(path.first, source)
            for destination in 0..<graph.vertexCount where destination != source {
                path = sut.pathFromSource(to: destination)
                if graph.adjacencies(vertex: source).isEmpty {
                    XCTAssertTrue(path.isEmpty)
                } else {
                    if sut.hasPath(to: destination) {
                        XCTAssertEqual(path.first, source)
                        XCTAssertEqual(path.last, destination)
                        for i in 0..<(path.count - 1) {
                            let vertex = path[i]
                            let other = path[i + 1]
                            XCTAssertNotNil(graph.adjacencies(vertex: vertex).firstIndex(where: { $0.other(vertex) == other }))
                        }
                    } else {
                        XCTAssertTrue(path.isEmpty)
                    }
                }
            }
            
            sut = GraphPaths(graph: graph, source: source, buildPathsAdopting: .BreadthFirstSearch)
            path = sut.pathFromSource(to: source)
            XCTAssertEqual(path.count, 1)
            XCTAssertEqual(path.first, source)
            for destination in 0..<graph.vertexCount where destination != source {
                path = sut.pathFromSource(to: destination)
                if graph.adjacencies(vertex: source).isEmpty {
                    XCTAssertTrue(path.isEmpty)
                } else {
                    if sut.hasPath(to: destination) {
                        XCTAssertEqual(path.first, source)
                        XCTAssertEqual(path.last, destination)
                        for i in 0..<(path.count - 1) {
                            let vertex = path[i]
                            let other = path[i + 1]
                            XCTAssertNotNil(graph.adjacencies(vertex: vertex).firstIndex(where: { $0.other(vertex) == other }))
                        }
                    } else {
                        XCTAssertTrue(path.isEmpty)
                    }
                }
            }
        }
        
        graph = givenGraphWithEdges(kind: .undirected)
        for source in 0..<graph.vertexCount {
            sut = GraphPaths(graph: graph, source: source, buildPathsAdopting: .DeepFirstSearch)
            var path = sut.pathFromSource(to: source)
            XCTAssertEqual(path.count, 1)
            XCTAssertEqual(path.first, source)
            for destination in 0..<graph.vertexCount where destination != source {
                path = sut.pathFromSource(to: destination)
                if graph.adjacencies(vertex: source).isEmpty {
                    XCTAssertTrue(path.isEmpty)
                } else {
                    if sut.hasPath(to: destination) {
                        XCTAssertEqual(path.first, source)
                        XCTAssertEqual(path.last, destination)
                        for i in 0..<(path.count - 1) {
                            let vertex = path[i]
                            let other = path[i + 1]
                            XCTAssertNotNil(graph.adjacencies(vertex: vertex).firstIndex(where: { $0.other(vertex) == other }))
                        }
                    } else {
                        XCTAssertTrue(path.isEmpty)
                    }
                }
            }
            
            sut = GraphPaths(graph: graph, source: source, buildPathsAdopting: .BreadthFirstSearch)
            path = sut.pathFromSource(to: source)
            XCTAssertEqual(path.count, 1)
            XCTAssertEqual(path.first, source)
            for destination in 0..<graph.vertexCount where destination != source {
                path = sut.pathFromSource(to: destination)
                if graph.adjacencies(vertex: source).isEmpty {
                    XCTAssertTrue(path.isEmpty)
                } else {
                    if sut.hasPath(to: destination) {
                        XCTAssertEqual(path.first, source)
                        XCTAssertEqual(path.last, destination)
                        for i in 0..<(path.count - 1) {
                            let vertex = path[i]
                            let other = path[i + 1]
                            XCTAssertNotNil(graph.adjacencies(vertex: vertex).firstIndex(where: { $0.other(vertex) == other }))
                        }
                    } else {
                        XCTAssertTrue(path.isEmpty)
                    }
                }
            }
        }
    }
    
    func testPathFromSourceTo_memoizedResults() {
        var paths = Array<Array<Int>?>(repeating: nil, count: sut.graph.vertexCount)
        for destination in 0..<sut.graph.vertexCount {
            paths[destination] = sut.pathFromSource(to: destination)
            XCTAssertEqual(paths[destination], sut.pathFromSource(to: destination))
        }
    }
    
}
