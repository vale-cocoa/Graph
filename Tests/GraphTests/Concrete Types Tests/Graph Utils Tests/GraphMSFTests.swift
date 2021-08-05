//
//  GraphMSFTests.swift
//  GraphTests
//
//  Created by Valeriano Della Longa on 2021/08/03.
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

final class GraphMSFTests: XCTestCase {
    var sut: GraphMSF<AdjacencyList<WeightedEdge<Double>>>!
    
    let allAlgs = GraphMSF<AdjacencyList<WeightedEdge<Double>>>.Algorithm.allCases
    
    override func setUp() {
        super.setUp()
        
        let graph = givenGraphWithEdges(kind: GraphConnections.allCases.randomElement()!)
        let alg = givenRandomAlg()
        sut = GraphMSF(graph: graph, adopting: alg)
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - Given
    func givenRandomAlg() -> GraphMSF<AdjacencyList<WeightedEdge<Double>>>.Algorithm {
        .allCases.randomElement()!
    }
    
    func givenGraphWithNoEdges(kind: GraphConnections) -> AdjacencyList<WeightedEdge<Double>> {
        let vertexCount = Int.random(in: 10..<100)
        
        return AdjacencyList<WeightedEdge<Double>>(kind: kind, vertexCount: vertexCount)
    }
    
    func givenGraphWithEdges(kind: GraphConnections) -> AdjacencyList<WeightedEdge<Double>> {
        let edges = givenRandomWeightedEdges()
        
        return AdjacencyList(kind: kind, edges: edges)
    }
    
    func givenRandomSources<G: Graph>(_ graph: G) -> Set<Int> {
        var vertices = Array(0..<graph.vertexCount).shuffled()
        let k = Int.random(in: 0..<(graph.vertexCount - 1))
        vertices.removeLast(k)
        
        return Set(vertices)
    }
    
    func givenExpectedMSTAndUndirectedGraphWithParallelEdges() -> (expectedMST: Array<WeightedEdge<Double>>, graph: AdjacencyList<WeightedEdge<Double>>) {
        let expectedMST = givenEdgesConnectedOneToEachOtherAscending()
        var edges = expectedMST
        for edge in expectedMST.shuffled() {
            let parallel = WeightedEdge(tail: edge.tail, head: edge.head, weight: edge.weight + 10.0)
            edges.append(parallel)
        }
        let graph = AdjacencyList(kind: .undirected, edges: edges)
        
        return (expectedMST, graph)
    }
    
    func givenExpectedMSTAndUndirectedGraphWithSelfLoops() -> (expectedMST: Array<WeightedEdge<Double>>, graph: AdjacencyList<WeightedEdge<Double>>) {
        let expectedMST = givenEdgesConnectedOneToEachOtherAscending()
        var edges = expectedMST
        for edge in expectedMST.shuffled() {
            let parallel = WeightedEdge(tail: edge.tail, head: edge.tail, weight: edge.weight + 10.0)
            edges.append(parallel)
        }
        let graph = AdjacencyList(kind: .undirected, edges: edges)
        
        return (expectedMST, graph)
    }
    
    func givenKnownData() -> (expectedMST: Array<WeightedEdge<Double>>, graph: AdjacencyList<WeightedEdge<Double>>, expectedWeight: Double) {
        // Test data based on tinyEWG.txt and MST from Algorithms 4th edition book
        // by R. Sedgewick & K. Wayne
        
        var graph = AdjacencyList<WeightedEdge<Double>>(kind: .undirected, vertexCount: 8)
        var expectedMST: Array<WeightedEdge<Double>> = []
        
        let edge45 = WeightedEdge(tail: 4, head: 5, weight: 0.35)
        graph.add(edge: edge45)
        expectedMST.append(edge45)
        
        let edge47 = WeightedEdge(tail: 4, head: 7, weight: 0.37)
        graph.add(edge: edge47)
        
        let edge57 = WeightedEdge(tail: 5, head: 7, weight: 0.28)
        graph.add(edge: edge57)
        expectedMST.append(edge57)
        
        let edge07 = WeightedEdge(tail: 0, head: 7, weight: 0.16)
        graph.add(edge: edge07)
        expectedMST.append(edge07)
        
        let edge15 = WeightedEdge(tail: 1, head: 5, weight: 0.32)
        graph.add(edge: edge15)
        
        let edge04 = WeightedEdge(tail: 0, head: 4, weight: 0.38)
        graph.add(edge: edge04)
        
        let edge23 = WeightedEdge(tail: 2, head: 3, weight: 0.17)
        graph.add(edge: edge23)
        expectedMST.append(edge23)
        
        let edge17 = WeightedEdge(tail: 1, head: 7, weight: 0.19)
        graph.add(edge: edge17)
        expectedMST.append(edge17)
        
        let edge02 = WeightedEdge(tail: 0, head: 2, weight: 0.26)
        graph.add(edge: edge02)
        expectedMST.append(edge02)
        
        let edge12 = WeightedEdge(tail: 1, head: 2, weight: 0.36)
        graph.add(edge: edge12)
        
        let edge13 = WeightedEdge(tail: 1, head: 3, weight: 0.29)
        graph.add(edge: edge13)
        
        let edge27 = WeightedEdge(tail: 2, head: 7, weight: 0.34)
        graph.add(edge: edge27)
        
        let edge62 = WeightedEdge(tail: 6, head: 2, weight: 0.40)
        graph.add(edge: edge62)
        expectedMST.append(edge62)
        
        let edge36 = WeightedEdge(tail: 3, head: 6, weight: 0.52)
        graph.add(edge: edge36)
        
        let edge60 = WeightedEdge(tail: 6, head: 0, weight: 0.58)
        graph.add(edge: edge60)
        
        let edge64 = WeightedEdge(tail: 6, head: 4, weight: 0.93)
        graph.add(edge: edge64)
        
        return (expectedMST, graph, 1.81000)
    }
    
    // MARK: - Tests
    func testInit() {
        let graph = givenGraphWithEdges(kind: GraphConnections.allCases.randomElement()!)
        let alg = givenRandomAlg()
        sut = GraphMSF(graph: graph, adopting: alg)
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.graph, graph)
        XCTAssertEqual(sut.algorithm, alg)
    }
    
    func test_whenGraphIsDirected_thenMSFAndWeightsAreNil() {
        let graph = givenGraphWithEdges(kind: .directed)
        for alg in allAlgs {
            sut = GraphMSF(graph: graph, adopting: alg)
            XCTAssertNil(sut.msf)
            XCTAssertNil(sut.weights)
        }
    }
    
    func test_whenGraphIsUndirectedAndHasZeroVertices_thenMSFAndWeightsAreEmpty() {
        let graph = AdjacencyList<WeightedEdge<Double>>(kind: .undirected, vertexCount: 0)
        for alg in allAlgs {
            sut = GraphMSF(graph: graph, adopting: alg)
            XCTAssertEqual(sut.msf?.isEmpty, true)
            XCTAssertEqual(sut.weights?.isEmpty, true)
        }
    }
    
    func test_whenGraphIsUndirectedAndHasSomeVerticesButZeroEdges_thenMSFAndWeightsHaveSameCountOfGraphVerticesAndAllMSFElementsAreEmptyAndAllWeightsElementsAreNil() {
        let graph = givenGraphWithNoEdges(kind: .undirected)
        for alg in allAlgs {
            sut = GraphMSF(graph: graph, adopting: alg)
            guard
                let msf = sut.msf,
                let weights = sut.weights
            else {
                XCTFail("msf or weights were nil for undirected graph")
                return
            }
            XCTAssertEqual(msf.count, graph.vertexCount)
            XCTAssertEqual(weights.count, graph.vertexCount)
            XCTAssertTrue(msf.allSatisfy({ $0.isEmpty }))
            XCTAssertTrue(weights.allSatisfy({ $0 == nil }))
        }
    }
    
    func test_whenGraphIsUndirectedAndIsOneConnectedComponent_thenMSFAndWeightsHaveJustOneElementAndMSFElementIsNotEmptyAndWeightsElementIsNotNil() {
        let edges = givenEdgesConnectedOneToEachOtherAscending()
        let graph = AdjacencyList(kind: .undirected, edges: edges)
        for alg in allAlgs {
            sut = GraphMSF(graph: graph, adopting: alg)
            guard
                let msf = sut.msf,
                let weights = sut.weights
            else {
                XCTFail("msf or weights were nil for undirected graph")
                return
            }
            XCTAssertEqual(msf.count, 1)
            XCTAssertEqual(weights.count, 1)
            guard
                let mst = msf.first,
                let weight = weights.first
            else {
                continue
            }
            
            XCTAssertFalse(mst.isEmpty)
            XCTAssertNotNil(weight)
        }
    }
    
    func test_whenGraphIsUndirectedAndHasMoreThanOneConnectedComponents_thenMSFAndWeightsHaveSameCountOfComponents() throws {
        let edges = givenRandomWeightedEdges()
        let graph = AdjacencyList(kind: .undirected, edges: edges)
        let cc = GraphStronglyConnectedComponents(graph: graph)
        try XCTSkipIf(cc.count <= 1)
        for alg in allAlgs {
            sut = GraphMSF(graph: graph, adopting: alg)
            guard
                let msf = sut.msf,
                let weights = sut.weights
            else {
                XCTFail("msf or weights were nil for undirected graph")
                return
            }
            XCTAssertEqual(msf.count, cc.count)
            XCTAssertEqual(weights.count, cc.count)
            // We also do tests of mst and weight for each
            // connected component of the graph:
            for (idx, (mst, weight)) in zip(msf, weights).enumerated() {
                if cc.stronglyConnectedComponent(with: idx).count > 1 {
                    // When connected component has more than one vertex,
                    // then its mst is not empty and its weight is not nil:
                    XCTAssertFalse(mst.isEmpty)
                    XCTAssertNotNil(weight)
                } else {
                    // When connected component has just one vertex, then
                    // its mst is empty and its weight is nil:
                    XCTAssertTrue(mst.isEmpty)
                    XCTAssertNil(weight)
                }
            }
            // We also test for connected components ids matching indices of msf:
            assertMSFIndicesAreSameValuesOfConnectedComponents()
        }
    }
    
    func testPrimLazyAlgorithm_withUndirectedGraphUniqueConnectectedComponentNoParallelEdgesNorSelfLoops() {
        let edges = givenEdgesConnectedOneToEachOtherAscending()
        let graph = AdjacencyList(kind: .undirected, edges: edges)
        sut = GraphMSF(graph: graph, adopting: .primLazyAlgorithm)
        let expectedWeight: Double = edges.reduce(0.0, { $0 + $1.weight })
        XCTAssertEqual(sut.weights!.first!!, expectedWeight, accuracy: 0.000001)
        assertContainsSameUndirectedWeightedEdges(lhs: sut.msf?.first, rhs: edges)
    }
    
    func testPrimEagerAlgorithm_withUndirectedGraphUniqueConnectectedComponentNoParallelEdgesNorSelfLoops() {
        let edges = givenEdgesConnectedOneToEachOtherAscending()
        let graph = AdjacencyList(kind: .undirected, edges: edges)
        sut = GraphMSF(graph: graph, adopting: .primEagerAlgorithm)
        let expectedWeight: Double = edges.reduce(0.0, { $0 + $1.weight })
        XCTAssertEqual(sut.weights!.first!!, expectedWeight, accuracy: 0.000001)
        assertContainsSameUndirectedWeightedEdges(lhs: sut.msf?.first, rhs: edges)
    }
    
    func testKruskalAlgorithm_withUndirectedGraphUniqueConnectectedComponentNoParallelEdgesNorSelfLoops() {
        let edges = givenEdgesConnectedOneToEachOtherAscending()
        let graph = AdjacencyList(kind: .undirected, edges: edges)
        sut = GraphMSF(graph: graph, adopting: .kruskalAlgorithm)
        let expectedWeight: Double = edges.reduce(0.0, { $0 + $1.weight })
        XCTAssertEqual(sut.weights!.first!!, expectedWeight, accuracy: 0.000001)
        assertContainsSameUndirectedWeightedEdges(lhs: sut.msf?.first, rhs: edges)
    }
    
    func testAlgorithms_produceIdenticalResultsForTheSameGraph() {
        let edges = givenRandomWeightedEdges()
        let graph = AdjacencyList(kind: .undirected, edges: edges)
        var results: [GraphMSF<AdjacencyList<WeightedEdge<Double>>>.Algorithm : (msf: [[WeightedEdge<Double>]]?, weights: [Double?]?)] = [:]
        for alg in allAlgs {
            sut = GraphMSF(graph: graph, adopting: alg)
            results[alg] = (sut.msf, sut.weights)
        }
        
        for alg in results.keys {
            let thisAlgResult = results[alg]!
            for otherAlg in results.keys where otherAlg != alg {
                let otherAlgResult = results[otherAlg]!
                assertEqualResults(lhs: thisAlgResult, rhs: otherAlgResult)
            }
        }
    }
    
    func testPrimsLazyAlgorithm_withUndirectedGraphUniqueConnectedComponentContainingParallelEdges() {
        let (expectedMST, graph) = givenExpectedMSTAndUndirectedGraphWithParallelEdges()
        let expectedWeight: Double = expectedMST.reduce(0.0, { $0 + $1.weight })
        
        sut = GraphMSF(graph: graph, adopting: .primLazyAlgorithm)
        XCTAssertEqual(sut.msf?.count, 1)
        XCTAssertEqual(sut.weights?.count, 1)
        XCTAssertEqual(sut.weights!.first!!, expectedWeight, accuracy: 0.000001)
        assertContainsSameUndirectedWeightedEdges(lhs: sut.msf?.first, rhs: expectedMST)
    }
    
    func testPrimsEagerAlgorithm_withUndirectedGraphUniqueConnectedComponentContainingParallelEdges() {
        let (expectedMST, graph) = givenExpectedMSTAndUndirectedGraphWithParallelEdges()
        let expectedWeight: Double = expectedMST.reduce(0.0, { $0 + $1.weight })
        
        sut = GraphMSF(graph: graph, adopting: .primEagerAlgorithm)
        XCTAssertEqual(sut.msf?.count, 1)
        XCTAssertEqual(sut.weights?.count, 1)
        XCTAssertEqual(sut.weights!.first!!, expectedWeight, accuracy: 0.000001)
        assertContainsSameUndirectedWeightedEdges(lhs: sut.msf?.first, rhs: expectedMST)
    }
    
    func testKruskalAlgorithm_withUndirectedGraphUniqueConnectedComponentContainingParallelEdges() {
        let (expectedMST, graph) = givenExpectedMSTAndUndirectedGraphWithParallelEdges()
        let expectedWeight: Double = expectedMST.reduce(0.0, { $0 + $1.weight })
        
        sut = GraphMSF(graph: graph, adopting: .kruskalAlgorithm)
        XCTAssertEqual(sut.msf?.count, 1)
        XCTAssertEqual(sut.weights?.count, 1)
        XCTAssertEqual(sut.weights!.first!!, expectedWeight, accuracy: 0.000001)
        assertContainsSameUndirectedWeightedEdges(lhs: sut.msf?.first, rhs: expectedMST)
    }
    
    func testPrimsLazyAlgorithm_withUndirectedGraphUniqueConnectedComponentContainingSelfLoops() {
        let (expectedMST, graph) = givenExpectedMSTAndUndirectedGraphWithSelfLoops()
        let expectedWeight: Double = expectedMST.reduce(0.0, { $0 + $1.weight })
        
        sut = GraphMSF(graph: graph, adopting: .primLazyAlgorithm)
        XCTAssertEqual(sut.msf?.count, 1)
        XCTAssertEqual(sut.weights?.count, 1)
        XCTAssertEqual(sut.weights!.first!!, expectedWeight, accuracy: 0.000001)
        assertContainsSameUndirectedWeightedEdges(lhs: sut.msf?.first, rhs: expectedMST)
    }
    
    func testPrimsEagerAlgorithm_withUndirectedGraphUniqueConnectedComponentContainingSelfLoops() {
        let (expectedMST, graph) = givenExpectedMSTAndUndirectedGraphWithSelfLoops()
        let expectedWeight: Double = expectedMST.reduce(0.0, { $0 + $1.weight })
        
        sut = GraphMSF(graph: graph, adopting: .primEagerAlgorithm)
        XCTAssertEqual(sut.msf?.count, 1)
        XCTAssertEqual(sut.weights?.count, 1)
        XCTAssertEqual(sut.weights!.first!!, expectedWeight, accuracy: 0.000001)
        assertContainsSameUndirectedWeightedEdges(lhs: sut.msf?.first, rhs: expectedMST)
    }
    
    func testKruskalAlgorithm_withUndirectedGraphUniqueConnectedComponentContainingSelfLoops() {
        let (expectedMST, graph) = givenExpectedMSTAndUndirectedGraphWithSelfLoops()
        let expectedWeight: Double = expectedMST.reduce(0.0, { $0 + $1.weight })
        
        sut = GraphMSF(graph: graph, adopting: .kruskalAlgorithm)
        XCTAssertEqual(sut.msf?.count, 1)
        XCTAssertEqual(sut.weights?.count, 1)
        XCTAssertEqual(sut.weights!.first!!, expectedWeight, accuracy: 0.000001)
        assertContainsSameUndirectedWeightedEdges(lhs: sut.msf?.first, rhs: expectedMST)
    }
    
    func testPrimLazyAlgorithm_withUndirectedGraphUniqueConnectedComponentFromKnownSolution() {
        let (expectedMST, graph, expectedWeight) = givenKnownData()
        
        sut = GraphMSF(graph: graph, adopting: .primLazyAlgorithm)
        XCTAssertEqual(sut.msf?.count, 1)
        XCTAssertEqual(sut.weights?.count, 1)
        XCTAssertEqual(sut.weights!.first!!, expectedWeight, accuracy: 0.000001)
        assertContainsSameUndirectedWeightedEdges(lhs: sut.msf?.first, rhs: expectedMST)
    }
    
    func testPrimEagerAlgorithm_withUndirectedGraphUniqueConnectedComponentFromKnownSolution() {
        let (expectedMST, graph, expectedWeight) = givenKnownData()
        
        sut = GraphMSF(graph: graph, adopting: .primEagerAlgorithm)
        XCTAssertEqual(sut.msf?.count, 1)
        XCTAssertEqual(sut.weights?.count, 1)
        XCTAssertEqual(sut.weights!.first!!, expectedWeight, accuracy: 0.000001)
        assertContainsSameUndirectedWeightedEdges(lhs: sut.msf?.first, rhs: expectedMST)
    }
    
    func testKruskalAlgorithm_withUndirectedGraphUniqueConnectedComponentFromKnownSolution() {
        let (expectedMST, graph, expectedWeight) = givenKnownData()
        
        sut = GraphMSF(graph: graph, adopting: .kruskalAlgorithm)
        XCTAssertEqual(sut.msf?.count, 1)
        XCTAssertEqual(sut.weights?.count, 1)
        XCTAssertEqual(sut.weights!.first!!, expectedWeight, accuracy: 0.000001)
        assertContainsSameUndirectedWeightedEdges(lhs: sut.msf?.first, rhs: expectedMST)
    }
    
    // MARK: - Helpers
    fileprivate func assertEqualResults(lhs: (msf: [[WeightedEdge<Double>]]?, weights: [Double?]?), rhs: (msf: [[WeightedEdge<Double>]]?, weights: [Double?]?), file: StaticString = #file, line: UInt = #line) {
        if let lMSF = lhs.msf {
            guard
                let rMSF = rhs.msf
            else {
                XCTFail("\(lMSF) is not equal to nil", file: file, line: line)
                
                return
            }
            
            guard
                lMSF.count == rMSF.count
            else {
                XCTFail("\(lMSF) is not equal to \(rMSF)", file: file, line: line)
                
                return
            }
            
            for (lMST, rMST) in zip(lMSF, rMSF) {
                assertContainsSameUndirectedWeightedEdges(lhs: lMST, rhs: rMST, file: file, line: line)
            }
        } else {
            guard
                rhs.msf == nil
            else {
                XCTFail("nil is not equal to \(rhs.msf!)", file: file, line: line)
                
                return
            }
        }
        
        if let lWeights = lhs.weights {
            guard
                let rWeights = rhs.weights
            else {
                XCTFail("\(lWeights) is not equal to nil", file: file, line: line)
                
                return
            }
            
            guard
                lWeights.count == rWeights.count
            else {
                XCTFail("\(lWeights) is not equal to \(rWeights)", file: file, line: line)
                
                return
            }
            
            for (lW, rW) in zip(lWeights, rWeights) {
                if let lW = lW {
                    guard
                        let rW = rW
                    else {
                        XCTFail("\(lWeights) is not equal to \(rWeights)", file: file, line: line)
                        
                        return
                    }
                    
                    XCTAssertEqual(lW, rW, accuracy: 0.00001, file: file, line: line)
                } else {
                    guard
                        rW == nil
                    else {
                        XCTFail("\(lWeights) is not equal to \(rWeights)", file: file, line: line)
                        
                        return
                    }
                }
            }
        } else {
            guard
                rhs.weights == nil
            else {
                XCTFail("nil is not equal to \(rhs.weights!)", file: file, line: line)
                
                return
            }
        }
    }
    
    fileprivate func assertMSFIndicesAreSameValuesOfConnectedComponents(file: StaticString = #file, line: UInt = #line) {
        guard
            sut.graph.kind == .undirected
        else { return }
        
        let cc = GraphStronglyConnectedComponents(graph: sut.graph)
        let msf = sut.msf!
        guard
            cc.count == msf.count
        else {
            XCTFail(file: file, line: line)
            
            return
        }
        
        for id in msf.indices {
            let mst = msf[id]
            let component = cc.stronglyConnectedComponent(with: id)
            for edge in mst {
                let vertex = edge.either
                let otherVertex = edge.other(vertex)
                guard
                    component.contains(vertex),
                    component.contains(otherVertex)
                else {
                    XCTFail(file: file, line: line)
                    
                    return
                }
            }
        }
    }
    
}


