//
//  main.swift
//  RangeTree
//
//  Created by Yung-Luen Lan on 2018/8/2.
//  Copyright © 2018 yllan. All rights reserved.
//

import Foundation
import os

let dots: [CGFloat] = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1]
let oneDimensionSearcher = RangeSearch1D(points: dots)
print(oneDimensionSearcher.query(lower: 1.2, upper: 2.05))



var t = Date()
var points: [CGPoint] = []
for i in 0..<1000 {
    for j in 0..<10000 {
        points.append(CGPoint(x: 1 * Double(i), y: 1 * Double(j)))
    }
}
os_log("%lf", Date().timeIntervalSince(t))

t = Date()
let twoDimensionRangeTree = CrossLinking2DRangeTree(points: points)
os_log("build %lf", Date().timeIntervalSince(t))
t = Date()
let ans = twoDimensionRangeTree.query(rect: CGRect(x: 3.0, y: 3.0, width: 502.0, height: 502.0))
os_log("query %lf", Date().timeIntervalSince(t))
print(ans.count)
let _ = readLine()
