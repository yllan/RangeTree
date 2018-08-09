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
    typealias Link = (leftIndex: UInt32, rightIndex: UInt32)
    typealias FlatTreeNode = (leftTree: UInt32, rightTree: UInt32, sortedByY: [UInt32], links: [Link])

    var treeNodes: [FlatTreeNode] = []
    
    func buildTree(range: CountableRange<Int>, array: [CGPoint]) -> UInt32 {
        if range.count == 0 {
            return UInt32.max
        } else if range.count == 1 {
            let idx = UInt32(treeNodes.count)
            treeNodes.append((leftTree: idx, rightTree: idx, sortedByY: [UInt32(range.startIndex)], links: []))
            return idx
        } else {
            let lRange = range.prefix(range.count / 2)
            let rRange = range.suffix(from: lRange.endIndex)
            
            let lTreeIdx = buildTree(range: lRange, array: array)
            let rTreeIdx = buildTree(range: rRange, array: array)
            
            // merging
            var sortedByY: [UInt32] = []
            var links: [Link] = []
            
            let lPoints = treeNodes[Int(lTreeIdx)].sortedByY
            let rPoints = treeNodes[Int(rTreeIdx)].sortedByY

            var lIdx = 0, rIdx = 0, idx = 0
            sortedByY = Array<UInt32>(repeating: 0, count: lPoints.count + rPoints.count)
            links = Array<Link>(repeating: (0, 0), count: lPoints.count + rPoints.count)
            
            while lIdx < lPoints.count || rIdx < rPoints.count {
                links[idx] = (leftIndex: UInt32(lIdx), rightIndex: UInt32(rIdx))
                if (rIdx == rPoints.count) ||
                    (lIdx < lPoints.count && array[Int(lPoints[lIdx])].y < array[Int(rPoints[rIdx])].y)
                {
                    sortedByY[idx] = lPoints[lIdx]
                    lIdx += 1
                } else {
                    sortedByY[idx] = rPoints[rIdx]
                    rIdx += 1
                }
                idx += 1
            }
            let treeIdx = UInt32(treeNodes.count)
            treeNodes.append((leftTree: lTreeIdx, rightTree: rTreeIdx, sortedByY: sortedByY, links: links))
            return treeIdx
        }
    }
    
    let sortedByX: [CGPoint]
    var tree: UInt32 = 0
    
    init(points: [CGPoint]) {
        sortedByX = points.sorted(by: { $0.x < $1.x })
        tree = buildTree(range: (0..<points.count), array: sortedByX)
    }
    
    func query(rect: CGRect) -> [CGPoint] {
        let l = sortedByX.indexOfFirst(where: { $0.x >= rect.minX })
        let r = sortedByX.indexOfFirst(where: { $0.x > rect.maxX })
        
        func searchTree(_ t: UInt32, nodeRange: CountableRange<Int>, searchRange: CountableRange<Int>, yRange: CountableRange<Int>) -> [UInt32] {
            let node = treeNodes[Int(t)]
            let trimmedSearchRange = searchRange.clamped(to: nodeRange)
                
            if trimmedSearchRange == nodeRange {
                return Array(node.sortedByY[yRange])
            } else if !trimmedSearchRange.isEmpty {
                guard yRange.startIndex < node.sortedByY.count else {
                    return []
                }
                    
                let leftY = treeNodes[Int(node.leftTree)].sortedByY
                let rightY = treeNodes[Int(node.rightTree)].sortedByY
                
                let leftYRange = Int(node.links[yRange.startIndex].leftIndex)..<(
                    yRange.endIndex == node.sortedByY.count ?
                        leftY.count :
                        Int(node.links[yRange.endIndex].leftIndex)
                )
                let rightYRange = Int(node.links[yRange.startIndex].rightIndex)..<(
                    yRange.endIndex == node.sortedByY.count ?
                        rightY.count :
                        Int(node.links[yRange.endIndex].rightIndex)
                )
                
                let lRange = nodeRange.prefix(nodeRange.count / 2)
                let rRange = nodeRange.suffix(from: lRange.endIndex)
                
                return searchTree(node.leftTree, nodeRange: lRange, searchRange: trimmedSearchRange, yRange: leftYRange) +
                       searchTree(node.rightTree, nodeRange: rRange, searchRange: trimmedSearchRange, yRange: rightYRange)
            } else { // no overlap
                return []
            }
        }
        
        let root = treeNodes[Int(tree)]
        let bottom = root.sortedByY.indexOfFirst(where: { sortedByX[Int($0)].y >= rect.minY })
        let top = root.sortedByY.indexOfFirst(where: { sortedByX[Int($0)].y > rect.maxY })
        return searchTree(tree, nodeRange: 0..<sortedByX.count, searchRange: l..<r, yRange: bottom..<top).map({ sortedByX[Int($0)] })
        
    }
}
