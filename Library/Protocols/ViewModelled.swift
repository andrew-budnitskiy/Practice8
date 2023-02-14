//
//  ViewModelled.swift
//  HRPoll_New
//
//  Created by Andrew on 23.12.2022.
//

import Foundation
import SwiftUI

public protocol ViewModelled {
    associatedtype ViewModelType: ViewModel
    var viewModel: ViewModelType { get }
    
}
