# PaylikeRequest - Paylike low-level request helper

[![build_test](/actions/workflows/build_test.yml/badge.svg?branch=main)](/actions/workflows/build_test.yml)

Request implementation for Swift

This implementation is based on [Paylike/JS-Request](https://github.com/paylike/request)

## Install

__SPM__:
```swift
// dependencies: 
.package(url: "git@github.com:paylike/swift-request.git", .upToNextMajor(from: "0.3.0"))

// target:
.product(name: "PaylikeRequest", package: "swift-request")
```

__Cocoapods__:
https://cocoapods.org/pods/PaylikeRequest
```ruby
pod 'PaylikeRequest'
```

## Usage

```swift
import PaylikeRequest

// ...

// optionally logging function can be overwritten
let httpClient = PaylikeHTTPClient(log: { item in
    print(item) // Item is encodable
})

let options = RequestOptions(
    withData: ["foo": "bar"]
)

// completion handler version
httpClient.sendRequest(
    to: URL(string: "http://localhost:8080/bar")!,
    withOptions: options
) { result in
    // handle result in callback style
}

// Async version
Task {
    let response = try await httpClient.sendRequest(
        to: URL(string: "http://localhost:8080/bar")!,
        withOptions: options
    )
}

// A more simple usage with options default parameters:

// ...

Task {
    let response = try await httpClient.sendRequest(
        to: URL(string: "http://localhost:8080/bar")!
    )
}

```
