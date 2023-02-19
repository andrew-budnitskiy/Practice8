//
//  CommonFunctions.swift
//  HRPoll_New
//
//  Created by Andrew on 21.12.2022.
//

import Foundation
import CoreData

public class CommonFunctions {

    public class Application {

        public static var version: String? {

            if let dictionary = Bundle.main.infoDictionary,
                let version = dictionary["CFBundleShortVersionString"] as? String,
                let build = dictionary["CFBundleVersion"] as? String {

                return "\(version).\(build)"

            } else {
                return nil
            }

        }

        public static var bundleIdentifier: String? {
            return Bundle.main.bundleIdentifier
        }

    }

    public class CoreData {

        public static var Ground: CoreDataGround {

            let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Database"
            return CoreDataGround.instance(withModelName: appName, withStoreName: appName)

        }

    }


}
