//
//  PublishedOnMain.swift
//  HRPoll_New
//
//  Created by Andrew on 27.12.2022.
//

import Foundation
import Combine
import SwiftUI

@propertyWrapper
public class PublishedOnMain<Value> {
  @Published var value: Value

  public var wrappedValue: Value {
    get { value }
    set { value = newValue }
  }

  public var projectedValue: AnyPublisher<Value, Never> {
    return $value
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }

  public init(wrappedValue initialValue: Value) {
    value = initialValue
  }

  public var t: Binding<Value> {
        Binding.init {
            self.wrappedValue
        } set: { q, a in
            self.wrappedValue = q
        }

    }

}
