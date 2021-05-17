//
//  WeightedEdgeTests.swift
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

final class WeightedEdgeTests: XCTestCase {
    var sut: WeightedEdge<Double>!
    
    override func setUp() {
        super.setUp()
        
        sut = WeightedEdge(vertices: givenTwoRandomAndDistinctVertices, weight: Double.random(in: 0.5..<10.5))
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    func testInitVerticesWeight() {
        let vertices = givenTwoRandomAndDistinctVertices
        let weight = Double.random(in: 0.5..<10.5)
        sut = WeightedEdge(vertices: vertices, weight: weight)
        
        XCTAssertEqual(sut.v, vertices.0)
        XCTAssertEqual(sut.w, vertices.1)
        XCTAssertEqual(sut.weight, weight)
    }
    
    func testInitTailHeadWeight() {
        let vertices = givenTwoRandomAndDistinctVertices
        let weight = Double.random(in: 0.5..<10.5)
        sut = WeightedEdge(tail: vertices.0, head: vertices.1, weight: weight)
        
        XCTAssertEqual(sut.v, vertices.0)
        XCTAssertEqual(sut.w, vertices.1)
        XCTAssertEqual(sut.weight, weight)
    }
    
    func testEither() {
        XCTAssertEqual(sut.either, sut.v)
        let newEither = sut.either + 100
        sut.either = newEither
        XCTAssertEqual(sut.either, newEither)
    }
    
    func testWeight() {
        let newWeight = sut.weight + 100
        sut.weight = newWeight
        XCTAssertEqual(sut.weight, newWeight)
    }
    
    func testOther() {
        XCTAssertEqual(sut.other(sut.v), sut.w)
        XCTAssertEqual(sut.other(sut.w), sut.v)
    }
    
    func testReversed() {
        let reversed = sut.reversed()
        XCTAssertEqual(reversed.v, sut.w)
        XCTAssertEqual(reversed.w, sut.v)
        XCTAssertEqual(reversed.weight, sut.weight)
    }
    
    func testReversedWeight() {
        let newWeight = Double.random(in: 10.5..<20.5)
        let reversed = sut.reversedWith(weight: newWeight)
        XCTAssertEqual(reversed.v, sut.w)
        XCTAssertEqual(reversed.w, sut.v)
        XCTAssertEqual(reversed.weight, newWeight)
    }
    
    func testSetOther() {
        let newEither = sut.either + 100
        let newOther = sut.other(sut.either) + 100
        sut.setOther(sut.either, to: newOther)
        XCTAssertEqual(sut.other(sut.either), newOther)
        sut.setOther(newOther, to: newEither)
        XCTAssertEqual(sut.either, newEither)
    }
    
    func testSetTail() {
        let newTail = sut.tail + 100
        sut.setTail(newTail)
        XCTAssertEqual(sut.tail, newTail)
    }
    
    func testSetHead() {
        let newHead = sut.head + 100
        sut.setHead(newHead)
        XCTAssertEqual(sut.head, newHead)
    }
    
    func testsCodable() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        do {
            let data = try encoder.encode(sut)
            do {
                let decoded = try decoder.decode(WeightedEdge<Double>.self, from: data)
                XCTAssertEqual(decoded, sut)
            } catch {
                XCTFail("Thrown error while decoding.")
            }
        } catch {
            XCTFail("Thrown error while encoding.")
        }
    }
    
    func testCodable_whenDecodingWithWrongWeight_thenThrows() throws {
        let data = try? JSONEncoder().encode(sut)
        try XCTSkipIf(data == nil, "Couldn't encode data.")
        
        XCTAssertThrowsError(try JSONDecoder().decode(WeightedEdge<Int>.self, from: data!))
    }
    
}
