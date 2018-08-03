//
//  Array+BinarySearch.swift
//  RangeTree
//
//  Created by Yung-Luen Lan on 2018/8/2.
//  Copyright © 2018 yllan. All rights reserved.
//

extension Array {
    // Assuming the array is ordered like this: [F, F, F, ... T, T, T]
    // This function find the index of first element evaluates to true.
    // Time complexity: O(lgn)
    func indexOfFirst(where f: (Element) -> Bool) -> Index {
        guard let last = self.last, f(last) else {
            return self.count
        }
        var idx: Int = 0
        var len: Int = self.count
        while len > 0 {
            let half = (len >> 1)
            let m = idx + half
            if f(self[m]) {
                len = half
            } else {
                idx = m + 1
                len = len - half - 1
            }
        }
        return idx
    }
}
