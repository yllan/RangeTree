//
//  main.swift
//  RangeTree
//
//  Created by Yung-Luen Lan on 2018/8/2.
//  Copyright © 2018 yllan. All rights reserved.
//

import Foundation

class RangeSearch1D<T: Comparable> {
    let sortedPoints: [T]
    init(points: [T]) {
        sortedPoints = points.sorted()
    }
    
    func query(lower: T, upper: T) -> ArraySlice<T> {
        let l = sortedPoints.indexOfFirst(where: { $0 >= lower })
        let r = sortedPoints.indexOfFirst(where: { $0 > upper })
        return sortedPoints[l..<r]
    }
}

let dots: [CGFloat] = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1]
let oneDimensionSearcher = RangeSearch1D(points: dots)
print(oneDimensionSearcher.query(lower: 1.2, upper: 2.05))

class Naive2DRangeTree {
    indirect enum Tree {
        case Empty
        case Node(leftTree: Tree, rightTree: Tree, range: CountableRange<Int>, sortedByY: [CGPoint])
        
        static func build(range: CountableRange<Int>, array: [CGPoint]) -> Tree {
            if range.count == 0 {
                return Tree.Empty
            } else if range.count == 1 {
                return Tree.Node(leftTree: .Empty, rightTree: .Empty, range: range, sortedByY: [array[range.startIndex]])
            } else {
                let lRange = range.prefix(range.count / 2)
                let rRange = range.suffix(from: lRange.endIndex)
                
                let lTree = build(range: lRange, array: array)
                let rTree = build(range: rRange, array: array)
                
                return Tree.Node(leftTree: lTree, rightTree: rTree, range: range, sortedByY: array[range].sorted(by: { $0.y < $1.y }))
            }
        }
    }

    let sortedByX: [CGPoint]
    let tree: Tree
    
    init(points: [CGPoint]) {
        sortedByX = points.sorted(by: { $0.x < $1.x })
        tree = Tree.build(range: (0..<points.count), array: sortedByX)
    }
    
    func query(rect: CGRect) -> [CGPoint] {
        let l = sortedByX.indexOfFirst(where: { $0.x >= rect.minX })
        let r = sortedByX.indexOfFirst(where: { $0.x > rect.maxX })
        
        func searchTree(_ t: Tree, searchRange: CountableRange<Int>) -> [CGPoint] {
            switch t {
            case .Empty:
                return []
            case .Node(let leftTree, let rightTree, let range, let sortedByY):
                let trimmedSearchRange = searchRange.clamped(to: range)
                if trimmedSearchRange == range {
                    let bottom = sortedByY.indexOfFirst(where: { $0.y >= rect.minY })
                    let top = sortedByY.indexOfFirst(where: { $0.y > rect.maxY })
                    return Array(sortedByY[bottom..<top])
                } else if !trimmedSearchRange.isEmpty {
                    return searchTree(leftTree, searchRange: trimmedSearchRange) + searchTree(rightTree, searchRange: trimmedSearchRange)
                } else { // no overlap
                    return []
                }
            }
        }
        
        return searchTree(tree, searchRange: l..<r)
    }
}

var points: [CGPoint] = []
for i in 0..<100 {
    for j in 0..<100 {
        points.append(CGPoint(x: 1 * Double(i), y: 1 * Double(j)))
    }
}
let twoDimensionRangeTree = Naive2DRangeTree(points: points)
print(twoDimensionRangeTree.query(rect: CGRect(x: 30.5, y: 30.5, width: 3.0, height: 3.0)))
