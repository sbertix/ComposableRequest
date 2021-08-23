//
//  Receivables+If.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 23/08/21.
//

import Foundation

public extension Receivables {
    // swiftlint:disable type_name
    /// A `struct` defining a requestable conditional statement.
    struct If<O1: Receivable, O2: Receivable> where O1.Success == O2.Success {
        /// The current state.
        public let condition: Bool
        /// The true condition generator.
        public let trueGenerator: () -> O1
        /// The false condition generator.
        public let falseGenerator: () -> O2

        /// Init.
        ///
        /// - parameters:
        ///     - condition: A valid `Bool`.
        ///     - trueGenerator: A valid generator.
        ///     - falseGenerator: A valid generator.
        public init(_ condition: Bool,
                    onTrue trueGenerator: @escaping () -> O1,
                    onFalse falseGenerator: @escaping () -> O2) {
            self.condition = condition
            self.trueGenerator = trueGenerator
            self.falseGenerator = falseGenerator
        }
    }
    // swiftlint:enable type_name
}

extension Receivables.If: Receivable {
    /// The associated success type.
    public typealias Success = O1.Success
}
