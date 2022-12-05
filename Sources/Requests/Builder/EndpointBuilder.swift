//
//  EndpointBuilder.swift
//  Core
//
//  Created by Stefano Bertagno on 04/12/22.
//

import Foundation

/// A `struct` defining a result builder capable of generating a single
/// endpoint from a collection of components.
///
/// This `resultBuilder` enforces the following rules:
/// - you **MUST** have at least `1` `Path`
/// - **successive** `Component`s of the same type,
///   `Path`s and `Response`s will inherit their previous
///   values, if supported, otherwise they will override it
/// - no explicit `Response` means `Single` will output
///   `DefaultResponse`
/// - `Endpoint`s only return themselves
@resultBuilder
public struct EndpointBuilder {     // swiftlint:disable:this convenience_type
    // MARK: Accept

    /// Turn a single component into a collection.
    ///
    /// - parameter expression: Some `Component`.
    /// - returns: Some `Components`.
    public static func buildExpression<C: Component>(_ expression: C) -> Components {
        .init([expression])
    }

    /// Turn a valid path into itself.
    ///
    /// - parameter expression: A valid `Path`.
    /// - returns: A valid `Path`.
    public static func buildExpression(_ expression: Path) -> Path {
        expression
    }

    /// Turn a valid response into itself.
    ///
    /// - parameter expression: A valid `Response`.
    /// - returns: A valid `Response`.
    public static func buildExpression<I, O>(_ expression: Response<I, O>) -> Response<I, O> {
        expression
    }

    /// Turn a valid endpoint into itself.
    ///
    /// - parameter expression: Some `Endpoint`.
    /// - returns: Some `Endpoint`.
    public static func buildExpression<E: Endpoint>(_ expression: E) -> E {
        expression
    }
    
    // MARK: Conditional
    
    /// Turn a single path into itself.
    ///
    /// - parameter component: A valid `Path`.
    /// - returns: A valid `Path`.
    public static func buildEither(first component: Path) -> Path {
        component
    }

    /// Turn a single path into itself.
    ///
    /// - parameter component: A valid `Path`.
    /// - returns: A valid `Path`.
    public static func buildEither(second component: Path) -> Path {
        component
    }
    
    /// Turn a single component into a collection.
    ///
    /// - parameter component: A valid `Path`.
    /// - returns: A valid `Path`.
    public static func buildOptional(_ component: Components?) -> Components {
        component ?? .init()
    }

    /// Turn a collction of components into itself.
    ///
    /// - parameter component: Some `Components`.
    /// - returns: Some `Components`.
    public static func buildEither(first component: Components) -> Components {
        component
    }

    /// Turn a collction of components into itself.
    ///
    /// - parameter component: Some `Components`.
    /// - returns: Some `Components`.
    public static func buildEither(second component: Components) -> Components {
        component
    }
    
    /// Turn an item into itself.
    ///
    /// - parameter component: Some item.
    /// - returns: Some item.
    public static func buildLimitedAvailability<T>(_ component: T) -> T {
        component
    }

    // MARK: Start

    /// Build an endpoint request, starting from some components.
    ///
    /// - parameter content: Some `Components`.
    /// - returns: Some `Components`.
    public static func buildPartialBlock(first content: Components) -> Components {
        content
    }

    /// Build an endpoint request, starting from a path.
    ///
    /// - parameter response: A valid `Path`.
    /// - returns: A valid `TupleItem`.
    public static func buildPartialBlock(first content: Path) -> TupleEndpoint<DefaultResponse> {
        .init(first: content, middle: .init(), last: .init { $0 })
    }

    /// Build an endpoint request, starting from the response.
    ///
    /// - paramter content: A valid `Response`.
    /// - returns: Some `Response`.
    public static func buildPartialBlock<O>(first content: Response<DefaultResponse, O>) -> Response<DefaultResponse, O> {
        content
    }

    /// Build an endpoint request, starting from some endpoint.
    ///
    /// - parameter content: Some `Endpoint`.
    /// - returns: Some `Endpoint`.
    public static func buildPartialBlock<E: Endpoint>(first content: E) -> E {
        content
    }

    // MARK: Accumulate from `Components`

    /// Accumulate an endpoint request, adding to some components.
    ///
    /// - parameters:
    ///     - accumulated: Some `Components`.
    ///     - next: Some `Components`.
    /// - returns: Some `Components`.
    public static func buildPartialBlock(accumulated: Components, next: Components) -> Components {
        var next = next
        next.inherit(from: accumulated)
        return next
    }

    /// Accumulate an endpoint request, adding to some components.
    ///
    /// - parameters:
    ///     - accumulated: Some `Components`.
    ///     - next: A valid `Path`.
    /// - returns: A valid `TupleItem`.
    public static func buildPartialBlock(accumulated: Components, next: Path) -> TupleEndpoint<DefaultResponse> {
        .init(first: next, middle: accumulated, last: .init { $0 })
    }

    /// Accumulate an endpoint request, adding to some components.
    ///
    /// - parameters:
    ///     - accumulated: Some `Components`.
    ///     - next: A valid `Response`.
    /// - returns: A valid `TupleItem`.
    public static func buildPartialBlock<O>(accumulated: Components, next: Response<DefaultResponse, O>) -> TupleItem<Components, Response<DefaultResponse, O>> {
        .init(first: accumulated, last: next)
    }

    // MARK: Accumulate from `Response`
    
    /// Accumulate a response, adding to some response.
    ///
    /// - parameters:
    ///     - accumulated: A valid `Response`.
    ///     - next: A valid `Response`.
    /// - returns: A valid `Response`.
    public static func buildPartialBlock<I, O>(accumulated: Response<DefaultResponse, I>, next: Response<I, O>) -> Response<DefaultResponse, O> {
        .init { try next.content(accumulated.content($0)) }
    }

    /// Accumulate an endpoint request, adding to some response.
    ///
    /// - parameters:
    ///     - accumulated: A valid `Response`.
    ///     - next: Some `Components`.
    /// - returns: A valid `TupleItem`.
    public static func buildPartialBlock<O>(accumulated: Response<DefaultResponse, O>, next: Components) -> TupleItem<Components, Response<DefaultResponse, O>> {
        .init(first: next, last: accumulated)
    }

    /// Accumulate an endpoint request, adding to some response.
    ///
    /// - parameters:
    ///     - accumulated: A valid `Response`.
    ///     - next: A valid `Path`.
    /// - returns: Some `Single`.
    public static func buildPartialBlock<O>(accumulated: Response<DefaultResponse, O>, next: Path) -> TupleEndpoint<O> {
        .init(first: next, middle: .init(), last: accumulated)
    }

    // MARK: Accumulate from `Components`, `Response`

    /// Accumulate an endpoint request, adding to a tuple item.
    ///
    /// - parameters:
    ///     - accumulated: A valid `TupleItem`.
    ///     - next: Some `Components`.
    /// - returns: A valid `TupleItem`.
    public static func buildPartialBlock<O>(accumulated: TupleItem<Components, Response<DefaultResponse, O>>, next: Components) -> TupleItem<Components, Response<DefaultResponse, O>> {
        var next = next
        next.inherit(from: accumulated.first)
        var accumulated = accumulated
        accumulated.first = next
        return accumulated
    }
    
    /// Accumulate an endpoint request, adding to a tuple item.
    ///
    /// - parameters:
    ///     - accumulated: A valid `TupleItem`.
    ///     - next: A valid `Response`.
    /// - returns: A valid `TupleItem`.
    public static func buildPartialBlock<I, O>(accumulated: TupleItem<Components, Response<DefaultResponse, I>>, next: Response<I, O>) -> TupleItem<Components, Response<DefaultResponse, O>> {
        .init(first: accumulated.first, last: .init { try next.content(accumulated.last.content($0)) })
    }

    /// Accumulate an endpoint request, adding to a tuple item.
    ///
    /// - parameters:
    ///     - accumulated: A valid `TupleItem`.
    ///     - next: A valid `Path`.
    /// - returns: Some `Single`.
    public static func buildPartialBlock<O>(accumulated: TupleItem<Components, Response<DefaultResponse, O>>, next: Path) -> TupleEndpoint<O> {
        .init(first: next, middle: accumulated.first, last: accumulated.last)
    }
    
    // MARK: Accumulate from `TupleEndpoint`.
    
    /// Accumulate an endpoint request, adding to a tuple item.
    ///
    /// - parameters:
    ///     - accumulated: A valid `TupleItem`.
    ///     - next: Some `Components`.
    /// - returns: A valid `TupleEndpoint`.
    public static func buildPartialBlock<O>(accumulated: TupleEndpoint<O>, next: Components) -> TupleEndpoint<O> {
        var next = next
        next.inherit(from: accumulated.middle)
        var accumulated = accumulated
        accumulated.middle = next
        return accumulated
    }
    
    /// Accumulate an endpoint request, adding to a tuple item.
    ///
    /// - parameters:
    ///     - accumulated: A valid `TupleEndpoint`.
    ///     - next: A valid `Response`.
    /// - returns: A valid `TupleEndpoint`.
    public static func buildPartialBlock<I, O>(accumulated: TupleEndpoint<I>, next: Response<I, O>) -> TupleEndpoint<O> {
        .init(first: accumulated.first, middle: accumulated.middle, last: .init { try next.content(accumulated.last.content($0)) })
    }

    /// Accumulate an endpoint request, adding to a tuple item.
    ///
    /// - parameters:
    ///     - accumulated: A valid `TupleEndpoint`.
    ///     - next: A valid `Path`.
    /// - returns: A valid `TupleEndpoint`.
    public static func buildPartialBlock<O>(accumulated: TupleEndpoint<O>, next: Path) -> TupleEndpoint<O> {
        var next = next
        next.inherit(from: accumulated.first)
        var accumulated = accumulated
        accumulated.first = next
        return accumulated
    }

    // MARK: Resolve
    
    /// Resolve a valid tuple endpoint.
    ///
    /// - parameter content: A valid `TupleEndpoint`.
    /// - returns: A valid `Single`.
    public static func buildFinalResult<O>(_ component: TupleEndpoint<O>) -> Single<O> {
        .init(
            path: component.first.path,
            components: component.middle.components,
            output: component.last.content
        )
    }

    /// Resolve some endpoint.
    ///
    /// - parameter content: Some `Endpoint`.
    /// - returns: Some `Endpoint`.
    public static func buildFinalResult<E: Endpoint>(_ component: E) -> E {
        component
    }
}
