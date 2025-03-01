import Foundation
import XCTest

/// Helper functions for comparing models in tests
struct ModelComparison {
    
    /// Compare two URLs for equality, handling nil values
    /// - Parameters:
    ///   - url1: The first URL
    ///   - url2: The second URL
    ///   - file: The file where the assertion is made
    ///   - line: The line where the assertion is made
    /// - Returns: True if the URLs are equal
    static func compareURLs(_ url1: URL?, _ url2: URL?, file: StaticString = #file, line: UInt = #line) -> Bool {
        switch (url1, url2) {
        case (nil, nil):
            return true
        case (let url1?, let url2?):
            let equal = url1.absoluteString == url2.absoluteString
            if !equal {
                XCTFail("URLs don't match: \(url1.absoluteString) vs \(url2.absoluteString)", file: file, line: line)
            }
            return equal
        default:
            XCTFail("One URL is nil and the other is not", file: file, line: line)
            return false
        }
    }
    
    /// Compare two dates for equality, handling nil values
    /// - Parameters:
    ///   - date1: The first date
    ///   - date2: The second date
    ///   - file: The file where the assertion is made
    ///   - line: The line where the assertion is made
    /// - Returns: True if the dates are equal
    static func compareDates(_ date1: Date?, _ date2: Date?, file: StaticString = #file, line: UInt = #line) -> Bool {
        switch (date1, date2) {
        case (nil, nil):
            return true
        case (let date1?, let date2?):
            // Compare dates with a small tolerance for floating point precision
            let timeInterval1 = date1.timeIntervalSince1970
            let timeInterval2 = date2.timeIntervalSince1970
            let equal = abs(timeInterval1 - timeInterval2) < 0.001
            if !equal {
                XCTFail("Dates don't match: \(date1) vs \(date2)", file: file, line: line)
            }
            return equal
        default:
            XCTFail("One date is nil and the other is not", file: file, line: line)
            return false
        }
    }
    
    /// Compare two arrays for equality
    /// - Parameters:
    ///   - array1: The first array
    ///   - array2: The second array
    ///   - compareElement: A closure that compares two elements
    ///   - file: The file where the assertion is made
    ///   - line: The line where the assertion is made
    /// - Returns: True if the arrays are equal
    static func compareArrays<T, U>(_ array1: [T], _ array2: [U], compareElement: (T, U) -> Bool, file: StaticString = #file, line: UInt = #line) -> Bool {
        guard array1.count == array2.count else {
            XCTFail("Array counts don't match: \(array1.count) vs \(array2.count)", file: file, line: line)
            return false
        }
        
        for i in 0..<array1.count {
            if !compareElement(array1[i], array2[i]) {
                XCTFail("Array elements at index \(i) don't match", file: file, line: line)
                return false
            }
        }
        
        return true
    }
    
    /// Compare two dictionaries for equality
    /// - Parameters:
    ///   - dict1: The first dictionary
    ///   - dict2: The second dictionary
    ///   - compareValue: A closure that compares two values
    ///   - file: The file where the assertion is made
    ///   - line: The line where the assertion is made
    /// - Returns: True if the dictionaries are equal
    static func compareDictionaries<K: Hashable, V1, V2>(_ dict1: [K: V1], _ dict2: [K: V2], compareValue: (V1, V2) -> Bool, file: StaticString = #file, line: UInt = #line) -> Bool {
        guard dict1.count == dict2.count else {
            XCTFail("Dictionary counts don't match: \(dict1.count) vs \(dict2.count)", file: file, line: line)
            return false
        }
        
        for (key, value1) in dict1 {
            guard let value2 = dict2[key] else {
                XCTFail("Key \(key) exists in first dictionary but not in second", file: file, line: line)
                return false
            }
            
            if !compareValue(value1, value2) {
                XCTFail("Dictionary values for key \(key) don't match", file: file, line: line)
                return false
            }
        }
        
        return true
    }
} 