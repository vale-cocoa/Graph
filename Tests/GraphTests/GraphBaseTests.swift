//
//  GraphTests.swift
//  GraphTests
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

import XCTest
@testable import Graph

class GraphBaseTests: XCTestCase {
    var sut: AdjacencyList<WeightedEdge<Double>>!
    
    override func setUp() {
        super.setUp()
        
        let vertexCount = Int.random(in: 1..<100)
        sut = AdjacencyList(kind: .undirected, vertexCount: vertexCount)
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - When
    func whenKindIsUndirected() {
        let vertexCount = Int.random(in: 10..<100)
        sut = AdjacencyList(kind: .undirected, vertexCount: vertexCount)
    }
    
    func whenKindIsDirected() {
        let vertexCount = Int.random(in: 10..<100)
        sut = AdjacencyList(kind: .directed, vertexCount: vertexCount)
    }
    
    func whenKindIsUndirectedAndContainsEdges() {
        sut = AdjacencyList(kind: .undirected, edges: givenRandomWeightedEdges())
    }
    
    func whenKindIsDirectedAndContainsEdges() {
        sut = AdjacencyList(kind: .directed, edges: givenRandomWeightedEdges())
    }
    
}

