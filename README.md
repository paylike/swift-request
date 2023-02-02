# PaylikeRequest - Paylike low-level request helper

[![build_test](https://github.com/kocsislaci/swift-request/actions/workflows/build_test.yml/badge.svg?branch=main)](https://github.com/kocsislaci/swift-request/actions/workflows/build_test.yml)

Request implementation for Swift

This implementation is based on [Paylike/JS-Request](https://github.com/paylike/request)

## Install

__SPM__:
```swift
// dependencies: 
.package(url: "git@github.com:paylike/swift-request.git", .upToNextMajor(from: "0.2.0"))

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

// ....

let requester = PaylikeRequester(log: { item in
    print(item) // Item is encodable
})
let options = RequestOptions()
options.method = "POST"
options.data = ["foo": "bar"]

let promise = requester.request(endpoint: "http://localhost:8080/bar", options: options)

// A more simple usage with options default parameters:
// ...
let promise = requester.request(endpoint: "http://localhost:8080/bar")
```
