<br />
<img alt="Header" src="https://raw.githubusercontent.com/sbertix/ComposableRequest/master/Resources/header.png" height="72" />
<br />

[![Swift](https://img.shields.io/badge/Swift-5.0-%23DE5C43?style=flat&logo=swift)](https://swift.org)
[![codecov](https://codecov.io/gh/sbertix/ComposableRequest/branch/main/graph/badge.svg)](https://codecov.io/gh/sbertix/Swiftagram)
<br />
![iOS](https://img.shields.io/badge/iOS-9.0-8CFF96)
![macOS](https://img.shields.io/badge/macOS-10.10-8CFF96)
![tvOS](https://img.shields.io/badge/tvOS-9.0-8CFF96)
![watchOS](https://img.shields.io/badge/watchOS-2.0-8CFF96)

<br />

**ComposableRequest** is a networking layer based on a declarative interface, written in (modern) **Swift**.

It abstracts away `URLSession` implementation, in order to provide concise and powerful endpoint representations, thanks to the power of `Observable`s, compatible with [**Combine**](https://developer.apple.com/documentation/combine) but extremely powerful by themselves. 

It comes with `Storage` (inside of **ComposableStorage**), a way of caching `Storable` items, and related concrete implementations (e.g. `UserDefaultsStorage`, `KeychainStorage` – for which you're gonna need to add **ComposableStorageCrypto**, depending on [**Swiftchain**](https://github.com/sbertix/Swiftchain), together with the ability to provide the final user of your API wrapper to inject code and change the way your `Promise` stream will eventually output, allowing for easier pagination and authentication. 

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
1. Add **ComposableStorage** together with **ComposableRequest** for the full experience.

> Why not CocoaPods, or Carthage, or ~blank~?

Supporting multiple _dependency managers_ makes maintaining a library exponentially more complicated and time consuming.\
Furthermore, with the integration of the **Swift Package Manager** in **Xcode 11** and greater, we expect the need for alternative solutions to fade quickly.

<details><summary><strong>Targets</strong></summary>
    <p>

- **ComposableRequest**, an HTTP client originally integrated in **Swiftagram**, the core library.\
It defines `Promise`s and their delayed counterparts, in order to tailor endpoint calls to your needs.\
It supports [`Combine`](https://developer.apple.com/documentation/combine) `Publisher`s out of the box.

- **ComposableStorage**, can be imported together with **ComposableRequest** to extend its functionality.     
    </p>
</details>

## Usage
Check out [**Swiftagram**](https://github.com/sbertix/Swiftagram) or visit the (_auto-generated_) [Documentation](https://sbertix.github.io/ComposableRequest) to learn about use cases.  

### Endpoint

As an implementation example, we can display some code related to the Instagram endpoint tasked with deleting a post.

```swift
/// A `module`-like `enum`.
public enum MediaEndpoint {
    /// Delete one of your own posts, matching `identifier`.
    /// Checkout https://github.com/sbertix/Swiftagram for more info.
    ///
    /// - parameter identifier: String
    /// - returns: A locked `AnyObservable`, waiting for authentication `HTTPCookie`s.
    func delete(_ identifier: String) -> LockSessionProvider<[HTTPCookie], AnyObservable<Bool, Error>> {
        // Wait for user defined values.
        LockSessionProvider { cookies, session in
            // Defer it so it only resumes when observed.
            Projectables.Deferred {
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
                    // Create the `Projectable`.
                    .project(session)
                    // Check it returned a valid media.
                    .map(\.data)
                    // Decode it inside a `Wrapper`, allowing to interrogate JSON
                    // representations of object without knowing them in advance.
                    // (It's literally the missing `AnyCodable`).
                    .wrap()
                    // Prepare the new request.
                    .flatMap { wrapper -> AnyProjectable<Bool, Error> in
                        guard let type = wrapper["items"][0].mediaType.int(),
                              [1, 2, 8].contains(type) else {
                            return Projectables.Just(false).eraseToAnyProjectable()
                        }
                        // Actually delete it now that we have all data.
                        return Request("https://i.instagram.com/api/v1/media")
                            .path(appending: identifier)
                            .path(appending: "delete/")
                            .query(appending: type == 2 ? "VIDEO" : "PHOTO", forKey: "media_type")
                            // This will be applied exactly as before, but you can add whaterver
                            // you need to it, as it will only affect this `Request`.
                            .header(appending: HTTPCookie.requestHeaderFields(with: cookies))
                            // Create the `Projectable`.
                            .project(session)
                            .map(\.data)
                            .wrap()
                            .map { $0.status == "ok" }
                    }
            }
            // Make sure it's observed from the main thread.
            .observe(on: .main)
            .eraseToAnyObservable()
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

/// Delete it.
MediaEndpoint.delete(identifier)
    .unlock(with: cookies)
    .session(.shared)
    .observe { print($0) }
    .resume()
    .retain()
```

Or, in case you want to have control over the dispose bag…

```swift
/// A valid post identifier.
let identifier: String = /* a valid String */
/// A valid array of cookies.
let cookies: [HTTPCookie] = /* an array of HTTPCookies */
/// The dispose bag.
let bin: Bin = .init()

/// Delete it.
MediaEndpoint.delete(identifier)
    .unlock(with: cookies)
    .session(.shared)
    .observe { print($0) }
    .resume()
    .store(in: bin)
```

<br />

> What if they're using **Combine**, instead?

**ComposableRequest** includes support for [**Combine**](https://developer.apple.com/documentation/combine), just add a few lines to the code…

```swift
/// A valid post identifier.
let identifier: String = /* a valid String */
/// A valid array of cookies.
let cookies: [HTTPCookie] = /* an array of HTTPCookies */
/// The dispose bag.
var bin: Set<AnyCancellable> = []

/// Delete it.
MediaEndpoint.delete(identifier)
    .unlock(with: cookies)
    .session(.shared)
    .publish()
    .sink(receiveCompletion: { _ in }, receiveValue: { print($0) })
    .store(in: &bin)
```

### Resume and cancel requests

> What about cancelling the request, or starting it a later date?



```swift
/// A valid post identifier.
let identifier: String = /* a valid String */
/// A valid array of cookies.
let cookies: [HTTPCookie] = /* an array of HTTPCookies */

/// Prepare the request.
let deferrable: Deferrable = MediaEndpoint.delete(identifier)
    .unlock(with: cookies)
    .session(.shared, controlledBy: source.token)
    .observe { print($0) }
// If `deferrable` is not retained, remember
// to call `retain` or `store(in:)` on it.
```

If you run the code above, you'll se `observe`'s `outputHandler` is no longer callsed as the underlying `URLSessionDataTask` is never actually fired. 
You're gonna need to resume it first. 

```swift
deferrable.resume()
```

If you wanna cancel it at a later stage, you can simply call `cancel`.

```swift
deferrable.cancel()
```

Please **keep in mind** cancelling a `URLSessionDataTask`-related `Projectable` will result in an `Error` being outputted: you're responsible for dealing with it yourself. 

### Caching
Caching of `Storable`s is provided through conformance to the `Storage` protocol, specifically by implementing either `ThrowingStorage` or `NonThrowingStorage`.  

The library comes with several concrete implementations.  
- `TransientStorage` should be used when no caching is necessary, and it's what `Authenticator`s default to when no `Storage` is provided.  
- `UserDefaultsStorage` allows for faster, out-of-the-box, testing, although it's not recommended for production as private cookies are not encrypted.  
- `KeychainStorage`, requiring you to add **ComposableStorageCrypto**, (**preferred**) stores them safely in the user's keychain.  
