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

let points: [CGFloat] = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1]
let oneDimensionSearcher = RangeSearch1D(points: points)
print(oneDimensionSearcher.query(lower: 1.2, upper: 2.05))
