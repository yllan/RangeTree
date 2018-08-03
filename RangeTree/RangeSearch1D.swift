//
//  RangeSearch1D.swift
//  RangeTree
//
//  Created by Yung-Luen Lan on 2018/8/3.
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
