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

import Dispatch
import AsyncNinja

open class ServicesFactory: ServicesLocator, ExecutionContext, ReleasePoolOwner {
  public var executor: Executor { return Executor.queue(_internalQueue) }
  public let releasePool = ReleasePool()

  private let _internalQueue = DispatchQueue(label: "services-factory")
  private var _cache: SimpleCache<ServiceAddress, ServiceActor>!

  public init(factoriesByServiceName: [String: (ServiceAddress, ServicesLocator) throws -> Future<ServiceActor>]) {
    _cache = SimpleCache(context: self) { (self, address) -> Future<ServiceActor> in
      guard let factory = factoriesByServiceName[address.name]
        else { throw ActorModelError.unknownServiceName }
      return try factory(address, self)
    }
  }

  open func perform(request: ServiceRequest) -> Channel<ServiceReport, ServiceResponse> {
    return actor(at: request.serviceAddress)
      .flatMap { try $0.perform(request: request) }
  }

  private func actor(at address: ServiceAddress) -> Future<ServiceActor> {
    return _cache.value(forKey: address)
  }
}
