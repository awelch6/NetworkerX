//
//  TestResetable.swift
//  RedditXTests
//
//  Created by Austin Welch on 9/6/19.
//  Copyright © 2019 Austin Welch. All rights reserved.
//

protocol TestResetable: class {
    
    /// Use this function to reset any counters you have set during your tests execution.
    func resetCounters()
    
    /// Use this function to reset any parameters that were set during your tests execution.
    func resetParameters()
    
    /// Convienence function that will reset all counters and parameters. 
    func resetAll()
}

extension TestResetable {
    func resetAll() {
        resetCounters()
        resetParameters()
    }
}
