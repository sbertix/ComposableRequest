# ComposableRequest
[![GitHub](https://img.shields.io/github/license/sbertix/ComposableRequest)](LICENSE)
[![codecov](https://codecov.io/gh/sbertix/ComposableRequest/branch/master/graph/badge.svg)](https://codecov.io/gh/sbertix/ComposableRequest) [![PayPal](https://img.shields.io/badge/support-PayPal-blue?style=flat&logo=paypal)](https://www.paypal.me/sbertix)

**ComposableRequest** is a library abstracting away **URLSession**, using Swift syntax at its finest.\
Starting in [**Swiftagram**](https://github.com/sbertix/Swiftagram), **ComposableRequest** is now a fully fledged library on its own.

<br/>

> Where can I use this?

**ComposableRequest** supports **iOS**, **macOS**, **watchOS**, **tvOS** and **Linux**.

## Status
![Status](https://github.com/sbertix/ComposableRequest/workflows/master/badge.svg)
![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/sbertix/ComposableRequest)

> What's next?

Check out our [milestones](https://github.com/sbertix/ComposableRequest/milestones), [issues](https://github.com/sbertix/ComposableRequests/issues) and the "WIP" [dashboard](https://github.com/sbertix/ComposableRequest/projects/1).

## Installation
### Swift Package Manager (Xcode 11 and above)
1. Select `File`/`Swift Packages`/`Add Package Dependency…` from the menu.
1. Paste `https://github.com/sbertix/ComposableRequest.git`.
1. Follow the steps.

`Requestable` also defines custom [`Publisher`](https://sbertix.github.io/ComposableRequest/Structs/PaginatablePublisher.html)s when linking against the [**Combine**](https://developer.apple.com/documentation/combine) framework.

> Why not CocoaPods, or Carthage, or ~blank~?

Supporting multiple _dependency managers_ makes maintaining a library exponentially more complicated and time consuming.\
Furthermore, with the integration of the **Swift Package Manager** in **Xcode 11** and greater, we expect the need for alternative solutions to fade quickly.

## Usage
Visit the (_auto-generated_) [Documentation](https://sbertix.github.io/ComposableRequest) to learn about use cases.  

## Contributions
[Pull requests](https://github.com/sbertix/ComposableRequest/pulls) and [issues](https://github.com/sbertix/ComposableRequest/issues) are more than welcome.
