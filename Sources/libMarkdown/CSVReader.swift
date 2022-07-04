/// TODO
///
/// REMOVE THIS (Unknown source)
///
/// use parsec parser instead
///
///

import Foundation


import class Foundation.NSCharacterSet

extension String {

    var isEmptyOrWhitespace: Bool
    {
        return isEmpty || trimmingCharacters(in: .whitespaces) == ""
    }

    var isNotEmptyOrWhitespace: Bool
    {
        return !isEmptyOrWhitespace
    }

}

public class CSVReader
{
    private let columnCount: Int
    public let headers: [String]
    public let keyedRows: [[String: String]]?
    public let rows: [[String]]
    
    public init(with string: String, separator: String = ",", headers: [String]? = nil)
  {
        var parsedLines = CSVReader.records(from: string.replacingOccurrences(of: "\r\n", with: "\n")).map
        { CSVReader.cells(forRow: $0, separator: separator) }
        self.headers = headers ?? parsedLines.removeFirst()
        rows = parsedLines
        columnCount = self.headers.count

        let tempHeaders = self.headers
        keyedRows = rows.map { field -> [String: String] in
            var row = [String: String]()
            for (index, value) in field.enumerated() where value.isNotEmptyOrWhitespace {
                if index < tempHeaders.count {
                    row[tempHeaders[index]] = value
                }
            }
            return row
        }
    }
    
    public convenience init(with string: String, headers: [String]?) {
        self.init(with: string, separator:",", headers:headers)
    }
    

    internal static func cells(forRow string: String, separator: String = ",") -> [String] {
        return CSVReader.split(separator, string: string)
    }

    internal static func records(from string: String) -> [String] {
        return CSVReader.split("\n", string: string).filter { $0.isNotEmptyOrWhitespace }
    }

    private static func split(_ separator: String, string: String) -> [String] {
        func oddNumberOfQuotes(_ string: String) -> Bool {
            return string.components(separatedBy: "\"").count % 2 == 0
        }

        let initial = string.components(separatedBy: separator)
        var merged = [String]()
        for newString in initial {
            guard let record = merged.last , oddNumberOfQuotes(record) == true else {
                merged.append(newString)
                continue
            }
            merged.removeLast()
            let lastElem = record + separator + newString
            merged.append(lastElem)
        }
        return merged
    }
}
