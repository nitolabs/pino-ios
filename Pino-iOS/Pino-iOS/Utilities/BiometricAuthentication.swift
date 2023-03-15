//
//  SecurityLockViewController.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 3/14/23.
//

import LocalAuthentication

struct BiometricAuthentication {
	private let laContext = LAContext()
	private let biometricsPolicy = LAPolicy.deviceOwnerAuthentication
	private var localizedReason = "Unlock device"
	private var error: NSError?

	public mutating func evaluate(onSuccess: @escaping () -> Void) {
		if canEvaluate() {
			laContext.evaluatePolicy(biometricsPolicy, localizedReason: localizedReason, reply: { isSuccess, error in
				DispatchQueue.main.async {
					if isSuccess {
						onSuccess()
					} else {
						print(error?.localizedDescription ?? "Authentication failed")
					}
				}
			})
		}
	}

	private mutating func canEvaluate() -> Bool {
		guard laContext.canEvaluatePolicy(biometricsPolicy, error: &error) else {
			// Maps error to our BiometricError
			return false
		}
		// Context can evaluate the Policy
		return true
	}
}
