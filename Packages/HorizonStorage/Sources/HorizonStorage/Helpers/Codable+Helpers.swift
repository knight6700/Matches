import Foundation

extension Encodable {
    var asDictionary: [String: Any] {
        let serialized = (try? JSONSerialization.jsonObject(with: encode, options: .allowFragments))
        return serialized as? [String: Any] ?? [String: Any]()
    }
    
    var encode: Data {
        (try? JSONEncoder().encode(self)) ?? Data()
    }
}

extension Data {
    func decode<T: Decodable>(_ object: T.Type) -> T? {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return (try decoder.decode(T.self, from: self))
        } catch let DecodingError.keyNotFound(key, context) {
            debugPrint("could not find key \(key) in JSON: \(context.debugDescription)")
        } catch let DecodingError.valueNotFound(type, context) {
            debugPrint("could not find type \(type) in JSON: \(context.debugDescription)")
        } catch let DecodingError.typeMismatch(type, context) {
            debugPrint("type mismatch for type \(type) in JSON: \(context.debugDescription)")
        } catch let DecodingError.dataCorrupted(context) {
            debugPrint("data found to be corrupted in JSON: \(context.debugDescription)")
        } catch let error as NSError {
            debugPrint("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
        } catch {
            debugPrint("Failed to Parse Object with this type: \(object)\nError: \(error)")
        }
        
        return nil
    }
}
