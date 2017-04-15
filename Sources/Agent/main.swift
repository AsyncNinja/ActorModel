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

import Foundation
import AsyncNinja
import ActorModel
import Entities
import PeopleService
import PeopleServer

// preparation
let sema = DispatchSemaphore(value: 0)

func makePeopleServer(
  withAddress address: ServiceAddress,
  servicesFactory: ServicesFactory
  ) throws -> Future<ServiceActor>
{
  guard let environment = address.spec.base as? Environment
    else { throw ActorModelError.wrongAddress }
  return future(after: 0.2) {
    PeopleServer(environment: environment, servicesFactory: servicesFactory)
  }
}

// make services factory by providing factories of services
let servicesFactory = ServicesFactory(factoriesByServiceName: [PeopleServer.name: makePeopleServer])

// obtain service
let peopleService = servicesFactory.peopleService(environment: .production)

// use service
peopleService.person(name: "John Appleseed").onSuccess {
  print("There is a person \($0)")
  sema.signal()
}

sema.wait()
