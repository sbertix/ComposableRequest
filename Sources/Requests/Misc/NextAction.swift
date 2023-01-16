//
//  NextAction.swift
//  Requests
//
//  Created by Stefano Bertagno on 05/12/22.
//

import Foundation

/// An `enum` listing all possible
/// `Loop` actions.
public enum NextAction<Next> {
    /// Move to the next page.
    case advance(to: Next)
    /// Repeat the same page.
    case `repeat`
    /// Complete the pagination.
    case `break`
}
