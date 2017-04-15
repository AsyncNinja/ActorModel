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

public extension ServicesFactory {
  func peopleService(environment: Environment) -> PeopleService {
    return PeopleServiceProxy(environment: environment, servicesFactory: self)
  }
}

private struct PeopleServiceProxy: ServiceProxy {
  var environment: Environment
  var servicesFactory: ServicesFactory
}

extension PeopleServiceProxy: PeopleService {
  // MARK: - get person for name
  func person(name: String) -> Future<Person> {
    let request = GetPersonForNameRequest(serviceAddress: address, personName: name)
    return perform(request: request).staticCast().map(executor: .immediate) {
      (response: GetPersonForNameResponse) -> Person in
      return response.person
    }
  }

  private struct GetPersonForNameRequest: PeopleServiceRequest {
    var serviceAddress: ServiceAddress
    var personName: String

    func perform(onPeopleService service: PeopleService) -> Channel<PeopleServiceReport, PeopleServiceResponse> {
      return service.person(name: personName)
        .flatMap { (person) -> Channel<PeopleServiceReport, PeopleServiceResponse> in
          let response = GetPersonForNameResponse(serviceAddress: self.serviceAddress, person: person)
          return .just(response)
      }
    }
  }

  private struct GetPersonForNameResponse: PeopleServiceResponse {
    var serviceAddress: ServiceAddress
    var person: Person
  }
}

protocol PeopleServiceRequest: ServiceRequest {
  func perform(onPeopleService service: PeopleService) -> Channel<PeopleServiceReport, PeopleServiceResponse>
}

extension PeopleServiceRequest {
  func perform(on service: Service) -> Channel<ServiceReport, ServiceResponse> {
    if let peopleService = service as? PeopleService {
      return perform(onPeopleService: peopleService).staticCast()
    } else {
      return .failed(ActorModelError.incorrectService)
    }
  }
}

protocol PeopleServiceReport: ServiceReport {
}

protocol PeopleServiceResponse: ServiceResponse {
}
