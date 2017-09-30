// swift-tools-version:4.0
//
//  Copyright (c) 2017 Anton Mironov
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom
//  the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

import PackageDescription

let package = Package(
  name: "ActorModel",
  products: [
    .executable(name: "Agent", targets: ["Agent"]),
    .library(name: "ActorModel", targets: ["ActorModel"]),
    .library(name: "ActorModelStatic", type: .static, targets: ["ActorModel"]),
    .library(name: "ActorModelDynamic", type: .dynamic, targets: ["ActorModel"])
  ],
  dependencies: [
    .package(url: "https://github.com/AsyncNinja/AsyncNinja.git", .branch("develop")),
    ],
  targets: [
    .target(name: "Agent", dependencies: ["PeopleServer"]),
    .target(name: "PeopleServer", dependencies: ["PeopleService"]),
    .target(name: "PeopleService", dependencies: ["ActorModel", "Entities"]),
    .target(name: "Entities", dependencies: []),
    .target(name: "ActorModel", dependencies: ["AsyncNinja"]),
    ]
)
