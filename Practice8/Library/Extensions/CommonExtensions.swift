//
//  CommonExtensions.swift
//  HRPoll_New
//
//  Created by Andrew on 20.12.2022.
//

import Foundation
import CommonCrypto
import Alamofire
import Combine
import SwiftUI

// MARK: - Dictionary
public extension Dictionary where Key == String, Value == Any {

    func merge(with other: [String: Any]) -> [String: Any] {
        return self.merging(other) { _, fromOther in fromOther }
    }

    var asHTTPHeaders: HTTPHeaders {

        HTTPHeaders(self.compactMap { key, value in
            if let value = value as? String {
                return HTTPHeader(name: key, value: value)
            } else {
                return nil
            }
        })

    }

}

// MARK: - HTTPHeaders
extension HTTPHeaders: Equatable {

    public static func ==(lhs: HTTPHeaders, rhs: HTTPHeaders) -> Bool {
        return lhs.elementsEqual(rhs)
    }

    mutating public func merge(with headers: HTTPHeaders) {
        for header in headers {
            self.add(header)
        }
    }

}

// MARK: - AFError
extension AFError {

    var asError: Error {
        self.underlyingError ?? self
    }

}


// MARK: - String

extension String.Index {
    func distance<S: StringProtocol>(in string: S) -> Int { string.distance(from: string.startIndex, to: self) }
}

public extension String {

    func greater(version: String) -> Bool {
        return compare(version, options: NSString.CompareOptions.numeric) == .orderedDescending
    }

    func less(version: String) -> Bool {
        return compare(version, options: NSString.CompareOptions.numeric) == .orderedAscending
    }

    static func random(length: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""

        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }

    func fromJSON() -> [String: Any] {
        if let data = data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            } catch {
                print("json \(error.localizedDescription)")
            }
        }
        return [:]
    }

    var sha1: String {
        let messageData = data(using: .utf8)!
        var digestData = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        messageData.withUnsafeBytes { buffer in
             guard let bufferBaseAddress = buffer.baseAddress else { return }
            _ = CC_SHA1(bufferBaseAddress, CC_LONG(buffer.count), &digestData)
        }
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }

    var sha1base64: String {
        let messageData = data(using: .utf8)!
        var digestData = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))

        _ = messageData.withUnsafeBytes { messageBytes in
            return CC_SHA1(messageBytes.baseAddress, CC_LONG(messageData.count), &digestData)
        }

        return Data(digestData).base64EncodedString()
    }

    var sha256: String {

        let messageData = data(using: .utf8)!
        var digestData = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        messageData.withUnsafeBytes {buffer in

            guard let bufferBaseAddress = buffer.baseAddress else { return }
           _ = CC_SHA256(bufferBaseAddress, CC_LONG(buffer.count), &digestData)

        }

        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }

    var asciiArray: [UInt32] {
        return unicodeScalars.filter{$0.isASCII}.map{$0.value}
    }

    func hash() -> Int32 {

        var h : Int32 = 0
        for i in self.asciiArray {
            h = 31 &* h &+ Int32(i) // Be aware of overflow operators,
        }
        return h

    }

    func escape(_ allowed: CharacterSet = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_")) -> String {
        return self.addingPercentEncoding(withAllowedCharacters: allowed) ?? self
    }

    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    func toDate(withFormat format: String) -> Date? {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format//"yyyy-MM-ddTHH:mm:ss-HH:mm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX

        if dateFormatter.date(from:self) == nil {
            print(self)
        }

        return dateFormatter.date(from:self)

    }

    private func nearestCharacter(ofSet set: CharacterSet,
                                  startingFrom startIndex: String.Index) -> (chr: Character, index: String.Index)? {

        if let resultCharacterRange = self.rangeOfCharacter(from: set,
                                                            range: startIndex..<self.endIndex) {
            let chr = String(self[resultCharacterRange])
            if let resultCharacter = chr.first {
                return (resultCharacter, resultCharacterRange.lowerBound)
            }
        }

        return nil

    }

    func carNumber(_ mask: String = "A 000 AA 000") -> String {

        var cyrillicSet: CharacterSet {
            return .init(charactersIn: "авекмнорстухАВЕКМНОРСТУХ")
        }

        var numberSet: CharacterSet {
            return .decimalDigits
        }

        let summarySet = cyrillicSet.union(numberSet)
        let cleanCarNumber = components(separatedBy: summarySet.inverted).joined()
        var lastCyrillicIndex: String.Index = cleanCarNumber.startIndex
        var lastNumberIndex: String.Index = cleanCarNumber.startIndex

        var result = ""
        var index = cleanCarNumber.startIndex
        for ch in mask {
            if index == cleanCarNumber.endIndex {
                break
            }
            if ch == "A" {
               if let nearestCyrData = cleanCarNumber.nearestCharacter(ofSet: cyrillicSet,
                                                                   startingFrom: lastCyrillicIndex) {
                   lastCyrillicIndex = cleanCarNumber.index(after: nearestCyrData.index)
                   result.append(nearestCyrData.chr)
                   index = cleanCarNumber.index(after: index)
               } else {
                   break
               }
            } else if ch == "0" {
                if let nearestNumData = cleanCarNumber.nearestCharacter(ofSet: numberSet,
                                                                        startingFrom: lastNumberIndex) {
                    lastNumberIndex = cleanCarNumber.index(after: nearestNumData.index)
                    result.append(nearestNumData.chr)
                    index = cleanCarNumber.index(after: index)
                } else {
                    break
                }
            } else if ch == " " {
                result.append(ch)
            }

        }
        return result.uppercased()
    }

    func phone(_ mask: String = "+X (XXX) XXX XX XX") -> String {
        let cleanPhoneNumber = components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        var result = ""
        var index = cleanPhoneNumber.startIndex
        for ch in mask {
            if index == cleanPhoneNumber.endIndex {
                break
            }
            if ch == "X" {
                result.append(cleanPhoneNumber[index])
                index = cleanPhoneNumber.index(after: index)
            } else {
                result.append(ch)
            }

        }
        return result
    }

    func phoneRu(_ mask: String = "+7 (XXX) XXX-XX-XX") -> String {

        var result = self
        if result.prefix(1) == "+" {
            if result.count > 1 {
                result.removeFirst(2)
            } else if result.count == 1 {
                result.removeFirst()
            }
        }
        return result.phone(mask)

    }

    func onlyDigits() -> String {

        return components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

    }

    func validateByDigits() -> Bool {

        let myCharSet = CharacterSet.decimalDigits
        if let scalar = UnicodeScalar.init(self) {
            return myCharSet.contains(scalar)
        } else {
            return true
        }

    }

    //Индексы вхождения подстроки в строку
    func indices(of occurrence: String) -> [Int] {
        var indices = [Int]()
        var position = startIndex
        while let range = range(of: occurrence, range: position..<endIndex) {
            let i = distance(from: startIndex,
                             to: range.lowerBound)
            indices.append(i)
            let offset = occurrence.distance(from: occurrence.startIndex,
                                             to: occurrence.endIndex) - 1
            guard let after = index(range.lowerBound,
                                    offsetBy: offset,
                                    limitedBy: endIndex) else {
                                        break
            }
            position = index(after: after)
        }
        return indices
    }

    //Ranges вхождения подстроки в строку
    func ranges(of searchString: String) -> [Range<String.Index>] {
        let _indices = indices(of: searchString)
        let count = searchString.count
        return _indices.map({ index(startIndex, offsetBy: $0)..<index(startIndex, offsetBy: $0+count) })
    }

    //CamelCase в отдельные слова
    var camelCaps: String {
            var newString: String = ""

            let upperCase = CharacterSet.uppercaseLetters
            for scalar in self.unicodeScalars {
                if upperCase.contains(scalar) {
                    newString.append(" ")
                }
                let character = Character(scalar)
                newString.append(character)
            }

            return newString
    }

    func indexOf(subString: String) -> Int? {

        if let range: Range<String.Index> = self.range(of: subString) {

            return self.distance(from: self.startIndex, to: range.lowerBound)

        } else {
            return nil
        }

    }

}

// MARK: - Publisher
extension Publisher {

    var asFlow: AnyPublisher<Flow, Failure> {
        self
            .map { value in
                return Flow.data(data: value)
            }
            .prepend(.pending)
            .eraseToAnyPublisher()
    }

}

extension Publisher where Output == Flow {

    func fromFlow<ResultType>() -> AnyPublisher<ResultType, Failure> {
        self
            .compactMap { flow in
                if case .data(let value) = flow,
                    let result = value as? ResultType {
                    return result
                } else {
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }

    var isPending: AnyPublisher<Bool, Never> {

        self
            .map { flow in
                if case .pending = flow {
                    return true
                } else {
                    return false
                }
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()

    }

    func connectTo(_ pendingSubject: CurrentValueSubject<Bool, Never>) -> AnyCancellable {
        
        return self
            .isPending
            .map({ value in
                value
            })
            .subscribe(pendingSubject)

    }

    func connectPending<RequestServiceType: RequestService, RouteType: Route>(to viewModel: CustomViewModel<RequestServiceType, RouteType>) -> Self {
        viewModel
            .pendingSubject
            .send(self.isPending)

        return self
    }

    func connectError<RequestServiceType: RequestService, RouteType: Route>(to viewModel: CustomViewModel<RequestServiceType, RouteType>,
                                                                            collecting bag: inout Set<AnyCancellable>) -> Self {

        self
            .sink { completion in
                if case .failure(let error) = completion {
                    viewModel.errorSubject.send(error)
                }
            } receiveValue: { _ in }
            .store(in: &bag)

        return self
    }


}

// MARK: - UIImage

extension Color: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .init(value)
    }
}


//MARK: - View

extension View {

    func push<RouteType: Route>(_ router: CustomRouter<RouteType>) -> some View {
        self.modifier(PushModifier(presentingView: router.binding(keyPath: \.pushing)))
    }

    func present<RouteType: Route>(_ router: CustomRouter<RouteType>) -> some View {
        self.modifier(PresentModifier(presentingView: router.binding(keyPath: \.presenting)))
    }

}
