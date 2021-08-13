//
//  GraphAcyclicSPTests.swift
//  GraphTests
//
//  Created by Valeriano Della Longa on 2021/08/13.
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

final class GraphAcyclicSPTests: XCTestCase {
    var sut: GraphAcyclicSP<AdjacencyList<WeightedEdge<Double>>>!
    
    override func setUp() {
        super.setUp()
        
        let vertexCount = Int.random(in: 10..<100)
        var edges: Array<WeightedEdge<Double>> = []
        for tail in 0..<(vertexCount / 2) {
            let weight = Double.random(in: 0.5..<10.5)
            edges.append(WeightedEdge(tail: tail, head: tail + (vertexCount / 2), weight: weight))
        }
        let graph = AdjacencyList(kind: .directed, edges: edges)
        let cycleUtil = GraphCycle(graph: graph)
        let source = (0..<graph.vertexCount).randomElement()!
        assert(cycleUtil.topologicalSort != nil)
        sut = GraphAcyclicSP(cycleUtil, source: source)!
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }

}
