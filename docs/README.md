<br />
<img alt="Header" src="https://raw.githubusercontent.com/sbertix/ComposableRequest/master/Resources/header.png" height="72" />
<br />

[![Swift](https://img.shields.io/badge/Swift-5.2-%23DE5C43?style=flat&logo=swift)](https://swift.org)
[![codecov](https://codecov.io/gh/sbertix/ComposableRequest/branch/main/graph/badge.svg)](https://codecov.io/gh/sbertix/ComposableRequest)
<br />
![iOS](https://img.shields.io/badge/iOS-12.0-8CFF96)
![macOS](https://img.shields.io/badge/macOS-10.14-8CFF96)
![tvOS](https://img.shields.io/badge/tvOS-12.0-8CFF96)
![watchOS](https://img.shields.io/badge/watchOS-5.0-8CFF96)

<br />

**ComposableRequest** is a networking layer based on a declarative interface, written in (modern) **Swift**.

It abstracts away `URLSession` implementation (or your preferred custom networking library), in order to provide concise and powerful endpoint representations, supporting, out-of-the-box, completion handlers, **Combine** `Publisher`s and _structured concurrencty_ (`async`/`await`) with a single definition. 

It comes with `Storage` (inside of **Storage**), a way of caching `Storable` items, and related concrete implementations (e.g. `UserDefaultsStorage`, `KeychainStorage` – for which you're gonna need to add **StorageCrypto**, depending on [**KeychainAccess**](https://github.com/kishikawakatsumi/KeychainAccess), together with the ability to provide the final user of your API wrapper to inject code through `Provider`s.

## Status
![push](https://github.com/sbertix/ComposableRequest/workflows/push/badge.svg)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/sbertix/ComposableRequest)

You can find all changelogs directly under every [release](https://github.com/sbertix/ComposableRequesst/releases).

> What's next?

**ComposableRequest** was initially [**Swiftagram**](https://github.com/sbertix/Swiftagram)'s networking layer and it still tends to follow roughly the same development cycle.

[Milestones](https://github.com/sbertix/ComposableRequest/milestones), [issues](https://github.com/sbertix/ComposableRequest/issues), are the best way to keep updated with active developement.

Feel free to contribute by sending a [pull request](https://github.com/sbertix/ComposableRequest/pulls).
Just remember to refer to our [guidelines](CONTRIBUTING.md) and [Code of Conduct](CODE_OF_CONDUCT.md) beforehand.

<p />

## Installation
### Swift Package Manager (Xcode 11 and above)
1. Select `File`/`Swift Packages`/`Add Package Dependency…` from the menu.
1. Paste `https://github.com/sbertix/ComposableRequest.git`.
1. Follow the steps.
1. Add **Storage** together with **Requests** for the full experience.

> Why not CocoaPods, or Carthage, or ~blank~?

Supporting multiple _dependency managers_ makes maintaining a library exponentially more complicated and time consuming.\
Furthermore, with the integration of the **Swift Package Manager** in **Xcode 11** and greater, we expect the need for alternative solutions to fade quickly.

<details><summary><strong>Targets</strong></summary>
    <p>

- **Requests**, an HTTP client originally integrated in **Swiftagram**, the core library.
- **Storage**
- **StorageCrypto**, depending on [**KeychainAccess**](https://github.com/kishikawakatsumi/KeychainAccess), can be imported together with **Storage** to extend its functionality.     
    </p>
</details>

## Usage

Check out [**Swiftagram**](https://github.com/sbertix/Swiftagram) or visit the (_auto-generated_) documentation for [**Requests**](https://sbertix.github.io/ComposableRequest/Requests/), [**Storage**](https://sbertix.github.io/ComposableRequest/Storage/) and [**StorageCrypto**](https://sbertix.github.io/ComposableRequest/StorageCrypto/) to learn about use cases.  

### Endpoint

As an implementation example, we can display some code related to the Instagram endpoint tasked with deleting a post.

```swift
public extension Request {
    /// An enum listing an error.
    enum DeleteError: Swift.Error { case invalid }
    
    /// Delete one of your own posts, matching `identifier`.
    /// Checkout https://github.com/sbertix/Swiftagram for more info.
    ///
    /// - parameter identifier: String
    /// - returns: A locked `AnyObservable`, waiting for authentication `HTTPCookie`s.
    func delete<R: Requester>(_ identifier: String) -> Providers.LockRequester<[HTTPCookie], R, R.Requested<Bool>> {
        // Wait for user defined values.
        .init { cookies, requester in
            // Fetch first info about the post to learn if it's a video or picture
            // as they have slightly different endpoints for deletion.
            Request("https://i.instagram.com/api/v1/media")
                .path(appending: identifier)
                .info   // Equal to `.path(appending: "info")`.
                // Wait for the user to `inject` an array of `HTTPCookie`s.
                // You should implement your own `model` to abstract away
                // authentication cookies, but as this is just an example
                // we leave it to you.
                .header(appending: HTTPCookie.requestHeaderFields(with: cookies))
                // Prepare for the actual request.
                .prepare(with: requester)
                // Check it returned a valid media.
                .map(\.data)
                // Decode it inside a `Wrapper`, allowing to interrogate JSON
                // representations of object without knowing them in advance.
                // (It's literally the missing `AnyCodable`).
                .decode()
                // Switch to a new request.
                .switch { wrapper throws -> R.Requested<Bool> in
                    guard let type = wrapper["items"][0].mediaType.int(),
                          [1, 2, 8].contains(type) else {
                        throw DeleteError.invalid
                    }
                    // Actually delete it now that we have all data.
                    return Request("https://i.instagram.com/api/v1/media")
                        .path(appending: identifier)
                        .path(appending: "delete/")
                        .query(appending: type == 2 ? "VIDEO" : "PHOTO", forKey: "media_type")
                        // This will be applied exactly as before, but you can add whaterver
                        // you need to it, as it will only affect this `Request`.
                        .header(appending: HTTPCookie.requestHeaderFields(with: cookies))
                        // Create the `Publisher`.
                        .prepare(with: requester)
                        .map(\.data)
                        .decode()
                        .map { $0.status == "ok" }
                        .requested(by: requester)
                }
                .requested(by: requester)
        }
    }
}
```

<br />

> How can the user then retreieve the information?

All the user has to do is…

```swift
/// A valid post identifier.
let identifier: String = /* a valid String */
/// A valid array of cookies.
let cookies: [HTTPCookie] = /* an array of HTTPCookies */
/// A *retained* collection of `AnyCancellable`s.
var bin: Set<AnyCancellable> = []

/// Delete it using completion handlers.
Request.delete(identifier)
    .unlock(with: cookies)
    .prepare(with: URLSessionCompletionRequester(session: .shared))
    .onSuccess { _ in } onFailure: { _ in }
    .resume()
    
[…]

/// Delete it using **Combine**.
Request.delete(identifier)
    .unlock(with: cookies)
    .prepare(with: URLSessionCombineRequester(session: .shared))    
    .sink { _ in } receiveValue: { print($0) }
    .store(in: &bin)

[…]

/// Delete it using _async/await_.
let result = try await Request.delete(identifier)
    .unlock(with: cookies)
    .prepare(with: .async(session: .shared))
```

### Resume and cancel requests

> What about cancelling the request, or starting it a later date?

Concrete implementation of `Receivable` might implement suspension and cancellation through their underlying types (like `URLSessionDataTask` or `Cancellable`).  

### Caching
Caching of `Storable`s is provided through conformance to the `Storage` protocol, specifically by implementing either `ThrowingStorage` or `NonThrowingStorage`.  

The library comes with several concrete implementations.  
- `TransientStorage` should be used when no caching is necessary, and it's what `Authenticator`s default to when no `Storage` is provided.  
- `UserDefaultsStorage` allows for faster, out-of-the-box, testing, although it's not recommended for production as private cookies are not encrypted.  
- `KeychainStorage`, requiring you to add **ComposableStorageCrypto**, (**preferred**) stores them safely in the user's keychain.  
-->
