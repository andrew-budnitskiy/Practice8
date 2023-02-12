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
public class PhoneRu {

  @Published var value: String = ""
  public var wrappedValue: String {
      get {  value.phoneRu() }
      set { value = newValue.phoneRu() }
  }

    public var projectedValue: Published<String>.Publisher {
        return self
            .$value

    }

    public init(wrappedValue initialValue: String) {
        self.value = initialValue
    }

}
