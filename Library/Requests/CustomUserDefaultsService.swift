//
//  CustomUserDefaultsService.swift
//  HRPoll_New
//
//  Created by Andrew on 21.12.2022.
//

import Foundation

public class CustomUserDefaultsService {

    open func setValue<T: Encodable>(_ value: T?,
                             forKey key: String,
                             usingEncoder encoder: JSONEncoder = JSONEncoder(),
                             in userDefaults: UserDefaults = UserDefaults.standard) {

        guard let value = value else {
            userDefaults.removeObject(forKey: key)
            return
        }

        if let data = try? encoder.encode(value) {
            userDefaults.setValue(data, forKey: key)
        }

        userDefaults.synchronize()
    }

    open func value<T: Decodable>(forKey key: String,
                                        usingDecoder decoder: JSONDecoder = JSONDecoder(),
                                        in userDefaults: UserDefaults = UserDefaults.standard) -> T? {
        do {
            if let data = userDefaults.value(forKey: key) as? Data {
                return try decoder.decode(T.self, from: data)
            } else {
                return nil
            }
        } catch {}
        return nil
    }

}
