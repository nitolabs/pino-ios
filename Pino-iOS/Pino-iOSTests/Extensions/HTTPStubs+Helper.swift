//
//  HTTPStubs+Helper.swift
//  Pino-iOSTests
//
//  Created by Sobhan Eskandari on 1/14/23.
//

import OHHTTPStubs

extension HTTPStubsDescriptor {
	public func store(in stubsDescriptor: inout [HTTPStubsDescriptor]) {
		stubsDescriptor.append(self)
	}
}
