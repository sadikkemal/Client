# Client Swift Package

This package provides a lightweight network layer mechanism for handling standard data fetching and Server-Sent Events (SSE) streaming. It includes support for custom request body encoders and response decoders, as well as logging and token-based authentication features.

## Features
- Standard data fetching with custom request body encoders and response decoders.
- Support for Server-Sent Events (SSE) streaming.
- Logging capabilities for debugging and monitoring.
- Token-based authentication support.
- Flexible configuration options.

## Installation

### Swift Package Manager

Add the following line to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/sadikkemal/Client.git", from: "1.0.0")
]
```

Then, import the package in your Swift code:

```swift
import Client
```

## Usage

### Configuration

First, configure the Client with your server details:

```swift
let configuration = Configuration(
    scheme: "https",
    host: "api.example.com",
    path: "/v1"
)
```

### Creating an Endpoint

Define an endpoint by conforming to the Endpoint protocol:

```swift
struct MyEndpoint: Endpoint {
    typealias RequestBodyEncoder = JsonRequestBodyEncoder<MyRequestBody>
    typealias ResponseDecoder = JsonResponseDecoder<MyResponse>

    var path: String { "/resource" }
    var queryItems: [String: String]? { ["key": "value"] }
    var httpMethod: HttpMethod { .get }
    var headers: [String: String] { ["Custom-Header": "value"] }
    var requestBody: MyRequestBody? { nil }
    var requestBodyEncoder: JsonRequestBodyEncoder<MyRequestBody> { .init() }
    var responseDecoder: JsonResponseDecoder<MyResponse> { .init() }
    var requiresAuthentication: Bool { true }
}
```

### Making Requests

Create a client instance and make requests:

```swift
let client = Client(
    configuration: configuration,
    tokenProvider: MyTokenProvider(),
    logger: MyLogger()
)

// Fetch data
Task {
    do {
        let response: MyResponse = try await client.data(MyEndpoint())
        print(response)
    } catch {
        print("Error: \(error)")
    }
}

// Stream data
do {
    let stream = try client.stream(MyEndpoint())
    for try await response in stream {
        print(response)
    }
} catch {
    print("Error: \(error)")
}
```

### Logging

Implement the Logging protocol to log messages:

```swift
public struct MyLogger: Logging {
    public func log(_ message: String) {
        print("Log: \(message)")
    }
}
```

### Authentication

Implement the TokenProviding protocol to handle token-based authentication:

```swift
public struct MyTokenProvider: TokenProviding {
    public var type: String { "Bearer" }
    public var credentials: String { "your_token_here" }
}
```

## Components

### DataSession

Handles fetching and decoding data from a URL session request.

### StreamSession

Handles streaming data from a URL session request and decoding each chunk.

### RequestBodyEncoding

Protocols and implementations for encoding request body data:

- RawRequestBodyEncoder
- JsonRequestBodyEncoder
- FormDataRequestBodyEncoder

### ResponseDecoding

Protocols and implementations for decoding response data:

- RawResponseDecoder
- JsonResponseDecoder

### ResponseValidating

Protocol and implementation for validating HTTP responses:

- StandardResponseValidator

### Client

Main class responsible for making network requests and handling responses.

### Configuration

Holds configuration details for the client, including scheme, host, port, and path.

### Endpoint

Protocol defining the requirements for a network endpoint.

## Licenses

This project is licensed under the MIT License.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.
