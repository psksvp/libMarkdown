//
//  Markdown.swift
//  MDEtcher
//
//  Created by psksvp on 12/1/20.
//  Copyright © 2020 psksvp. All rights reserved.
//

import Foundation
import CommonSwift

public protocol MarkdownFilter
{
  var targetPattern:String {get}
  func run(_ block: String) -> String?
}


public class Markdown
{
//  public class func headerFrom(position: String.Index) -> String?
//  {
//    
//  }

  public class func extractContentAndCaption(_ block: String) -> (content: String, caption: String)
  {
    let capPat = #"\s*caption:\s*(.*)"#
    if let capRange = block.range(of: capPat, options: [.regularExpression]),
       let cap = block[capRange].regexLift(usingPattern: capPat).first
    {
      let content = String(block[block.startIndex ..< capRange.lowerBound])
      return (content, cap)
    }
    else
    {
      return (block, "")
    }
  }
  
  public class func headerOutline(_ md: String) -> [String]?
  {
    md.ranges(ofRegex: #"^(.*?)[\n]"#).compactMap
    {
      r in md[r].hasPrefix("#") ? String(md[r]).trimmingCharacters(in: .whitespacesAndNewlines) : nil
    }
  }
  
  // filters
  public class func runfilters(_ md: String, additionalFilters: [MarkdownFilter] = [MarkdownFilter]()) -> String
  {
    return runFilters(filters: additionalFilters + [FilterAsciiMath(), FilterUnderlineText(), FilterMermaid(), FilterTableCSV()],
                       onMarkdown: md.replacingOccurrences(of: "---pagebreak---",
                                                          with: "<div style=\"page-break-after: always;\"></div>"))
  }
  
  ///////////////////////////////
  public class func runFilters(filters: [MarkdownFilter], onMarkdown md: String) -> String
  {
    var resultMD = md
    for f in filters
    {
      resultMD = runFilter(f, onMarkdown: resultMD)
    }
    return resultMD
  }
  
  public class func runFilter(_ f: MarkdownFilter, onMarkdown md: String) -> String
  {
    var result = md

    // refact this shity loop down here
    let pattern = f.targetPattern
    let regex = try? NSRegularExpression(pattern: pattern, options:[])
    for (_, mmBlock) in md.liftRegexPattern(pattern)
    {
      if let match = regex?.firstMatch(in: mmBlock,
                                       options: [],
                                       range: NSRange(mmBlock.startIndex..<mmBlock.endIndex, in: mmBlock)),
         let range = Range(match.range(at: 1), in: mmBlock),
         let filtered = f.run(String(mmBlock[range]))
      {
        result = result.replacingOccurrences(of: mmBlock, with: filtered)
      }
    }
    
    return result
  }
  
  
  public class FilterAsciiMath: MarkdownFilter
  {
    public var targetPattern: String
    {
      get { return #"<`(.*?)`>"# }
    }
    
    public func run(_ block: String) -> String?
    {
      return "`` `\(block.trim())` ``"
    }
  }
  
  public class FilterUnderlineText: MarkdownFilter
  {
    public var targetPattern: String
    {
      get { return #"=(.*?)="# }
    }
    
    public func run(_ block: String) -> String?
    {
      return "<u>\(block)</u>"
    }
  }
  
  
  public class FilterMermaid: MarkdownFilter
  {
    public var targetPattern: String
    {
      get {return #"(?s)~~~\s*mermaid\s*(.*?)~~~"#}
    }
    
    public func run(_ block: String) -> String?
    {
      let (content, caption) = Markdown.extractContentAndCaption(block)
      
      return """
             <figure>
             <div class="mermaid">
             \(content)
             </div>
             <figcaption>\(caption)</figcaption>
             </figure>
             """
    }
  }
  
  public class FilterTableCSV: MarkdownFilter
  {
    public var targetPattern: String
    {
      get {return #"(?s)~~~\s*csvtable\s*(.*?)~~~"#}
    }
    
    public func run(_ block: String) -> String?
    {
      func row(_ elements: [String]) -> String
      {
        """
        <tr>
        \(elements.map {"<th>\($0)</th>"}.joined(separator: " "))
        </tr>
        """
      }
      let (content, caption) = Markdown.extractContentAndCaption(block)
      let reader = CSVReader(with: content)

      return """
             <figure>
             <table>
             \(row(reader.headers))
             \(reader.rows.map{row($0)}.joined(separator: "\n"))
             </table>
             <figcaption>\(caption)</figcaption>
             </figure>
             """
    }
  }
  
}

