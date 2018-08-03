//
//  RangeSearch2D.swift
//  RangeTree
//
//  Created by Yung-Luen Lan on 2018/8/3.
//  Copyright © 2018 yllan. All rights reserved.
//

import Foundation

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
                
                // merging
                var sortedByY: [CGPoint] = []
                switch (lTree, rTree) {
                case let (.Node(_, _, _, lPoints), .Node(_, _, _, rPoints)):
                    var lIdx = 0, rIdx = 0, idx = 0
                    sortedByY = Array<CGPoint>(repeating: CGPoint.zero, count: lPoints.count + rPoints.count)
                    while lIdx < lPoints.count || rIdx < rPoints.count {
                        if lIdx < lPoints.count && rIdx < rPoints.count {
                            if lPoints[lIdx].y < rPoints[rIdx].y {
                                sortedByY[idx] = lPoints[lIdx]
                                lIdx += 1
                                idx += 1
                            } else {
                                sortedByY[idx] = rPoints[rIdx]
                                rIdx += 1
                                idx += 1
                            }
                        } else if lIdx < lPoints.count {
                            sortedByY[idx] = lPoints[lIdx]
                            lIdx += 1
                            idx += 1
                        } else {
                            sortedByY[idx] = rPoints[rIdx]
                            rIdx += 1
                            idx += 1
                        }
                    }
                default:
                    fatalError("Impossible!")
                    break
                }
                
                return Tree.Node(leftTree: lTree, rightTree: rTree, range: range, sortedByY: sortedByY)
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
            case let .Node(leftTree, rightTree, range, sortedByY):
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

class ReduceMemory2DRangeTree {
    indirect enum Tree {
        case Empty
        case Node(leftTree: Tree, rightTree: Tree, range: CountableRange<Int>, sortedByY: [UInt32])
        
        static func build(range: CountableRange<Int>, points: [CGPoint]) -> Tree {
            if range.count == 0 {
                return Tree.Empty
            } else if range.count == 1 {
                return Tree.Node(leftTree: .Empty, rightTree: .Empty, range: range, sortedByY: [UInt32(range.startIndex)])
            } else {
                let lRange = range.prefix(range.count / 2)
                let rRange = range.suffix(from: lRange.endIndex)
                
                let lTree = build(range: lRange, points: points)
                let rTree = build(range: rRange, points: points)
                
                // merging
                var sortedByY: [UInt32] = []
                switch (lTree, rTree) {
                case let (.Node(_, _, _, lPoints), .Node(_, _, _, rPoints)):
                    var lIdx = 0, rIdx = 0, idx = 0
                    sortedByY = Array<UInt32>(repeating: 0, count: lPoints.count + rPoints.count)
                    while lIdx < lPoints.count || rIdx < rPoints.count {
                        if lIdx < lPoints.count && rIdx < rPoints.count {
                            if points[Int(lPoints[lIdx])].y < points[Int(rPoints[rIdx])].y {
                                sortedByY[idx] = lPoints[lIdx]
                                lIdx += 1
                                idx += 1
                            } else {
                                sortedByY[idx] = rPoints[rIdx]
                                rIdx += 1
                                idx += 1
                            }
                        } else if lIdx < lPoints.count {
                            sortedByY[idx] = lPoints[lIdx]
                            lIdx += 1
                            idx += 1
                        } else {
                            sortedByY[idx] = rPoints[rIdx]
                            rIdx += 1
                            idx += 1
                        }
                    }
                default:
                    fatalError("Impossible!")
                    break
                }
                
                return Tree.Node(leftTree: lTree, rightTree: rTree, range: range, sortedByY: sortedByY)
            }
        }
    }
    
    let sortedByX: [CGPoint]
    let tree: Tree
    
    init(points: [CGPoint]) {
        sortedByX = points.sorted(by: { $0.x < $1.x })
        tree = Tree.build(range: (0..<points.count), points: sortedByX)
    }
    
    func query(rect: CGRect) -> [CGPoint] {
        let l = sortedByX.indexOfFirst(where: { $0.x >= rect.minX })
        let r = sortedByX.indexOfFirst(where: { $0.x > rect.maxX })
        
        func searchTree(_ t: Tree, searchRange: CountableRange<Int>) -> [CGPoint] {
            switch t {
            case .Empty:
                return []
            case let .Node(leftTree, rightTree, range, sortedByY):
                let trimmedSearchRange = searchRange.clamped(to: range)
                if trimmedSearchRange == range {
                    let bottom = sortedByY.indexOfFirst(where: { sortedByX[Int($0)].y >= rect.minY })
                    let top = sortedByY.indexOfFirst(where: { sortedByX[Int($0)].y > rect.maxY })
                    
                    return sortedByY[bottom..<top].map({ sortedByX[Int($0)] })
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

class CrossLinking2DRangeTree {
    
    typealias Link = (leftIndex: Int, rightIndex: Int, point: CGPoint)
    
    indirect enum Tree {
        case Empty
        case Node(leftTree: Tree, rightTree: Tree, range: CountableRange<Int>, sortedByY: [Link])
        
        static func build(range: CountableRange<Int>, array: [CGPoint]) -> Tree {
            if range.count == 0 {
                return Tree.Empty
            } else if range.count == 1 {
                return Tree.Node(leftTree: .Empty, rightTree: .Empty, range: range, sortedByY: [Link(leftIndex: 0, rightIndex: 0, point: array[range.startIndex])])
            } else {
                let lRange = range.prefix(range.count / 2)
                let rRange = range.suffix(from: lRange.endIndex)
                
                let lTree = build(range: lRange, array: array)
                let rTree = build(range: rRange, array: array)
                
                // merging
                var sortedByY: [Link] = []
                switch (lTree, rTree) {
                case let (.Node(_, _, _, lLinks), .Node(_, _, _, rLinks)):
                    var lIdx = 0, rIdx = 0, idx = 0
                    sortedByY = Array<Link>(repeating: Link(leftIndex: 0, rightIndex: 0, point: .zero), count: lLinks.count + rLinks.count)
                    
                    while lIdx < lLinks.count || rIdx < rLinks.count {
                        if (rIdx == rLinks.count) ||
                           (lIdx < lLinks.count && lLinks[lIdx].point.y < rLinks[rIdx].point.y)
                        {
                            sortedByY[idx].leftIndex = lIdx
                            sortedByY[idx].rightIndex = rIdx
                            sortedByY[idx].point = lLinks[lIdx].point
                            lIdx += 1
                            idx += 1
                        } else {
                            sortedByY[idx].leftIndex = lIdx
                            sortedByY[idx].rightIndex = rIdx
                            sortedByY[idx].point = rLinks[rIdx].point
                            rIdx += 1
                            idx += 1
                        }
                    }
                default:
                    fatalError("Impossible!")
                    break
                }
                
                return Tree.Node(leftTree: lTree, rightTree: rTree, range: range, sortedByY: sortedByY)
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
        
        func searchTree(_ t: Tree, searchRange: CountableRange<Int>, yRange: CountableRange<Int>) -> [CGPoint] {
            switch t {
            case .Empty:
                return []
            case let .Node(leftTree, rightTree, range, sortedByY):
                let trimmedSearchRange = searchRange.clamped(to: range)
                
                if trimmedSearchRange == range {
                    return []
                } else if !trimmedSearchRange.isEmpty {
                    guard yRange.startIndex < sortedByY.count else {
                        return []
                    }
                    
                    var leftYRange = 0..<0
                    var rightYRange = 0..<0
                    
                    switch (leftTree, rightTree) {
                    case let (.Node(_, _, _, leftY), .Node(_, _, _, rightY)):
                        leftYRange = (sortedByY[yRange.startIndex].leftIndex)..<(
                                        yRange.endIndex == sortedByY.count ?
                                        leftY.count :
                                        sortedByY[yRange.endIndex].leftIndex
                                     )
                        rightYRange = (sortedByY[yRange.startIndex].rightIndex)..<(
                            yRange.endIndex == sortedByY.count ?
                                rightY.count :
                                sortedByY[yRange.endIndex].rightIndex
                        )
                    default:
                        fatalError("Not good!")
                    }
                    return searchTree(leftTree, searchRange: trimmedSearchRange, yRange: leftYRange) + searchTree(rightTree, searchRange: trimmedSearchRange, yRange: rightYRange)
                } else { // no overlap
                    return []
                }
            }
        }
        
        switch tree {
            case let .Node(_, _, _, sortedByY):
                let bottom = sortedByY.indexOfFirst(where: { $0.point.y >= rect.minY })
                let top = sortedByY.indexOfFirst(where: { $0.point.y > rect.maxY })
                return searchTree(tree, searchRange: l..<r, yRange: bottom..<top)
            default:
                return []
        }
    }
}
