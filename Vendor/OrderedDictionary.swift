/***********************************************************************
* The MIT License (MIT)
*
* Copyright (c) 2014 iMacbaszii
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*************************************************************************/

//
//  OrderedDictionary.swift
//  FlickrSearch
//
//  Created by Main Account on 9/14/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

struct OrderedDictionary<KeyType: Hashable, ValueType> {

  typealias ArrayType = [KeyType]
  typealias DictionaryType = [KeyType: ValueType]
   
  var array = ArrayType()
  var dictionary = DictionaryType()
  var count: Int {
    return self.array.count
  }
  
  // 1
  mutating func insert(value: ValueType, forKey key: KeyType, atIndex index: Int) -> ValueType?
  {
    var adjustedIndex = index
   
    // 2
    let existingValue = self.dictionary[key]
    if existingValue != nil {
      // 3
      let existingIndex = find(self.array, key)!
   
      // 4
      if existingIndex < index {
        adjustedIndex--
      }
      self.array.removeAtIndex(existingIndex)
    }
   
    // 5
    self.array.insert(key, atIndex:adjustedIndex)
    self.dictionary[key] = value
   
    // 6
    return existingValue
  }

  // 1
  mutating func removeAtIndex(index: Int) -> (KeyType, ValueType)
  {
    // 2
    precondition(index < self.array.count, "Index out-of-bounds")
   
    // 3
    let key = self.array.removeAtIndex(index)
   
    // 4
    let value = self.dictionary.removeValueForKey(key)!
   
    // 5
    return (key, value)
  }

  // 1
  subscript(key: KeyType) -> ValueType? {
    // 2(a)
    get {
      // 3
      return self.dictionary[key]
    }
    // 2(b)
    set {
      // 4
      if let index = find(self.array, key) {
      } else {
        self.array.append(key)
      }
   
      // 5
      self.dictionary[key] = newValue
    }
  }

  subscript(index: Int) -> (KeyType, ValueType) {
    // 1
    get {
      // 2
      precondition(index < self.array.count, 
                   "Index out-of-bounds")
   
      // 3
      let key = self.array[index]
   
      // 4
      let value = self.dictionary[key]!
   
      // 5
      return (key, value)
    }
  }

}