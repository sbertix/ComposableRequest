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
/// - you _CAN_ have **at most** `1` `Response`
/// - **successive** `Component`s of the same type,
///   or `Path`s will call `inherit` together with their
///   previous values
/// - non-`Single` `Endpoint`s only return themselves or a type-erased version of themeselves.
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
    public static func buildExpression<O>(_ expression: Response<O>) -> Response<O> {
        expression
    }

    /// Turn a valid endpoint into itself.
    ///
    /// - parameter expression: Some `Endpoint`.
    /// - returns: Some `Endpoint`.
    public static func buildExpression<E: Endpoint>(_ expression: E) -> E {
        expression
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
    public static func buildPartialBlock(first content: Path) -> TupleItem<Path, Components> {
        .init(first: content, last: .init())
    }

    /// Build an endpoint request, starting from the response.
    ///
    /// - paramter content: A valid `Response`.
    /// - returns: Some `Response`.
    public static func buildPartialBlock<O>(first content: Response<O>) -> Response<O> {
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
    public static func buildPartialBlock(accumulated: Components, next: Path) -> TupleItem<Path, Components> {
        .init(first: next, last: accumulated)
    }

    /// Accumulate an endpoint request, adding to some components.
    ///
    /// - parameters:
    ///     - accumulated: Some `Components`.
    ///     - next: A valid `Response`.
    /// - returns: A valid `TupleItem`.
    public static func buildPartialBlock<O>(accumulated: Components, next: Response<O>) -> TupleItem<Components, Response<O>> {
        .init(first: accumulated, last: next)
    }

    // MARK: Accumulate from `Response`

    /// Accumulate an endpoint request, adding to some response.
    ///
    /// - parameters:
    ///     - accumulated: A valid `Response`.
    ///     - next: Some `Components`.
    /// - returns: A valid `TupleItem`.
    public static func buildPartialBlock<O>(accumulated: Response<O>, next: Components) -> TupleItem<Components, Response<O>> {
        .init(first: next, last: accumulated)
    }

    /// Accumulate an endpoint request, adding to some response.
    ///
    /// - parameters:
    ///     - accumulated: A valid `Response`.
    ///     - next: A valid `Path`.
    /// - returns: Some `Single`.
    public static func buildPartialBlock<O>(accumulated: Response<O>, next: Path) -> Single<O> {
        .init(path: next.path, components: .init(), output: accumulated.content)
    }

    // MARK: Accumulate from `Path`, `Components`

    /// Accumulate an endpoint request, adding to a tuple item.
    ///
    /// - parameters:
    ///     - accumulated: A valid `TupleItem`.
    ///     - next: A valid `Path`.
    /// - returns: A valid `TupleItem`.
    public static func buildPartialBlock(accumulated: TupleItem<Path, Components>, next: Path) -> TupleItem<Path, Components> {
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
    ///     - next: Some `Components`.
    /// - returns: A valid `TupleItem`.
    public static func buildPartialBlock(accumulated: TupleItem<Path, Components>, next: Components) -> TupleItem<Path, Components> {
        var next = next
        next.inherit(from: accumulated.last)
        var accumulated = accumulated
        accumulated.last = next
        return accumulated
    }

    /// Accumulate an endpoint request, adding to a tuple item.
    ///
    /// - parameters:
    ///     - accumulated: A valid `TupleItem`.
    ///     - next: Some `Response`.
    /// - returns: Some `Single`.
    public static func buildPartialBlock<O>(accumulated: TupleItem<Path, Components>, next: Response<O>) -> Single<O> {
        .init(path: accumulated.first.path, components: accumulated.last.components, output: next.content)
    }

    // MARK: Accumulate from `Components`, `Response`

    /// Accumulate an endpoint request, adding to a tuple item.
    ///
    /// - parameters:
    ///     - accumulated: A valid `TupleItem`.
    ///     - next: Some `Components`.
    /// - returns: A valid `TupleItem`.
    public static func buildPartialBlock<O>(accumulated: TupleItem<Components, Response<O>>, next: Components) -> TupleItem<Components, Response<O>> {
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
    ///     - next: A valid `Path`.
    /// - returns: Some `Single`.
    public static func buildPartialBlock<O>(accumulated: TupleItem<Components, Response<O>>, next: Path) -> Single<O> {
        .init(path: next.path, components: accumulated.first.components, output: accumulated.last.content)
    }

    // MARK: Resolve

    /// Resolve a valid tuple item.
    ///
    /// - parameter content: A valid `TupleItem`.
    /// - returns: A valid `TupleItem`.
    public static func buildFinalResult(_ component: TupleItem<Path, Components>) -> TupleItem<Path, Components> {
        component
    }

    /// Resolve some endpoint.
    ///
    /// - parameter content: Some `Endpoint`.
    /// - returns: Some `Endpoint`.
    public static func buildFinalResult<E: Endpoint>(_ component: E) -> E {
        component
    }

    /// Resolve some single endpoint.
    ///
    /// - parameter content: Some `SingleEndpoint`.
    /// - returns: Some `Endpoint`.
    public static func buildFinalResult<E: SingleEndpoint>(_ component: E) -> E {
        component
    }

    /// Resolve some loop endpoint.
    ///
    /// - parameter content: Some `LoopEndpoint`.
    /// - returns: Some `Endpoint`.
    public static func buildFinalResult<E: LoopEndpoint>(_ component: E) -> E {
        component
    }

    /// Resolve some single endpoint.
    ///
    /// - parameter content: Some `SingleEndpoint`.
    /// - returns: Some `Endpoint`.
    public static func buildFinalResult<E: SingleEndpoint>(_ component: E) -> AnySingleEndpoint<E.Output> {
        component.eraseToAnySingleEndpoint()
    }

    /// Resolve some loop endpoint.
    ///
    /// - parameter content: Some `LoopEndpoint`.
    /// - returns: Some `Endpoint`.
    public static func buildFinalResult<E: LoopEndpoint>(_ component: E) -> AnyLoopEndpoint<E.Output> {
        component.eraseToAnyLoopEndpoint()
    }
}
