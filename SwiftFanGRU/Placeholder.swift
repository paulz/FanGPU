//
//  Placeholder.swift
//  SwiftFanGRU
//
//  Created by Paul Zabelin on 5/26/19.
//  Copyright © 2019 Paul Zabelin. All rights reserved.
//

import Foundation
/** Workaround for
 dyld: Library not loaded: @rpath/libswiftSwiftOnoneSupport.dylib
 by forcing loading Swift support library
 see: https://stackoverflow.com/questions/40986082/dyld-library-not-loaded-rpath-libswiftswiftononesupport-dylib
*/
class Test {
  func a() { print ("something") }
}
