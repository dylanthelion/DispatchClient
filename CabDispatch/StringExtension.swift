//
//  StringExtension.swift
//  CabDispatch
//
//  Created by Dylan on 5/14/15.
//  Copyright (c) 2015 Dylan. All rights reserved.
//

import Foundation

extension String {
    
    subscript(range: Range<Int>) -> String {
        //let subString = self[advance(range.startIndex, range.endIndex - range.startIndex, countElements(self))]
        let subString = self[advance(startIndex, range.startIndex)..<advance(startIndex, range.endIndex)]
        return subString
    }
    
    func getNumericPostscript() -> Int? {
        
        if(self.characters.count == 0) {
            return nil
        }
        
        var end : String.Index = self.endIndex.predecessor()
        
        while (Int(String(self[end])) != nil) {
            end = end.predecessor()
        }
        
        end = end.successor()
        
        let stringRange : Range = end...self.endIndex.predecessor()
        
        return Int(String(self[stringRange]))
    }
}