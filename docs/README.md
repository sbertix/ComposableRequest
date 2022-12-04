<br />
<img alt="Header" src="https://raw.githubusercontent.com/sbertix/ComposableRequest/master/Resources/header.png" height="72" />
<br />

[![Swift](https://img.shields.io/badge/Swift-5.7-%23DE5C43?style=flat&logo=swift)](https://swift.org)
<br />
![iOS](https://img.shields.io/badge/iOS-13.0-8CFF96)
![macOS](https://img.shields.io/badge/macOS-10.15-8CFF96)
![tvOS](https://img.shields.io/badge/tvOS-13.0-8CFF96)
![watchOS](https://img.shields.io/badge/watchOS-6.0-8CFF96)

<br />

**ComposableRequest** is a networking layer based on a declarative interface, written in (modern) **Swift**.

It abstracts away `URLSession` implementation, in order to provide concise and powerful endpoint representations (both for their requests and responses), supporting, out-of-the-box, **Combine** `Publisher`s and _structured concurrency_ (`async`/`await`) with a single definition. 

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
    /// - parameter identifier: A valid `String`.
    /// - returns: A locked `AnySingleEndpoint`, waiting for authentication `HTTPCookie`s.
    func delete(_ identifier: String) -> Providers.Lock<[HTTPCookie], AnySingleEndpoint<Bool>> {
        // Wait for user defined values.
        .init { cookies in
            // Fetch first info about the post to learn if it's a video or picture
            // as they have slightly different endpoints for deletion.
            Single {
                Path("https://i.instagram.com/api/v1/media/\(identifier)/info")
                 // Wait for the user to `inject` an array of `HTTPCookie`s.
                // You should implement your own `model` to abstract away
                // authentication cookies, but as this is just an example
                // we leave it to you.
                Headers(HTTPCookie.requestHeaderFields(with: cookies))
                // Decode it inside an `AnyDecodable`, allowing to interrogate JSON
                // representations of object without knowing them in advance.
                Response {
                    let output = try JSONDecoder().decode(AnyDecodable.self, from: $0)
                    guard let type = output.items[0].mediaType.int,
                                [1,2, 8].contains(type) else { 
                        throw DeleteError.invalid
                    }
                    return type
                }
            }.switch { 
                Path("https://i.instagram.com/api/v1/media/\(identifier)/delete")
                Query($0 == 2 ? "VIDEO" : "PHOTO", forKey: "media_type")
                // This will be applied exactly as before, but you can add whaterver
                // you need to it, as it will only affect this `Request`.
                Headers(HTTPCookie.requestHeaderFields(with: cookies))
                Response {
                    let output = try JSONDecoder().decode(AnyDecodable.self, from: $0)
                    return $0.status.bool ?? false
                }
            }
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

/// Delete it using **Combine**.
Request.delete(identifier)
    .unlock(with: cookies)
    .resolve(with: .shared)     // The shared `URLSession`.
    .sink { _ in } receiveValue: { print($0) }
    .store(in: &bin)

[…]

/// Delete it using _async/await_.
let result = try await Request.delete(identifier)
    .unlock(with: cookies)
    .resolve(with: .shared)
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
