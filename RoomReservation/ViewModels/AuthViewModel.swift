//
//  LoginFormModel.swift
//  Authenticator
//
//  Created by Martina Reyes on 5/16/25.
//

import SwiftUI
import Combine

class LoginFormModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
}

class SignUpFormModel: ObservableObject {
    @Published var username = ""
    @Published var userEmail = ""
    @Published var password = ""
    @Published var confirmPassword = ""
}
