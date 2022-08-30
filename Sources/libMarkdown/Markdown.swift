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
  
  public class func headerOutline(_ md: String) -> [String]?
  {
    func headers() -> [Substring]
    {
      md.split(separator: "\n").filter { isHeader(String($0)) }
    }
    
    func isHeader(_ line: String) -> Bool
    {
      for h in ["######", "#####", "####", "###", "##", "#"]
      {
        if line.hasPrefix(h)
        {
          return true
        }
      }
      
      return false
    }
    
    func removeHash(_ s: String) -> String
    {
      func hash2space(_ c: Character) -> Character
      {
        return c == "#" ? " " : c
      }
      
      let m = s.map
      {
        hash2space($0)
      }
      
      return String(m)
    }
    
    let ol = headers().map
    {
      //removeHash(String($0))
      String($0)
    }

    return ol.count > 0 ? ol : nil
  }
  
  // filters
  public class func runfilters(_ md: String) -> String
  {
    return runFilters(filters: [FilterAsciiMath(), FilterUnderlineText(), FilterMermaid(), FilterTableCSV()],
                      onMarkdown: md)
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
      return """
      <figure>
      <div class="mermaid">
      \(block)
      </div>
      <figcaption>Fig.1 - Trulli, Puglia, Italy.</figcaption>
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
      
      let reader = CSVReader(with: block)

      return """
             <figure>
             <table>
             \(row(reader.headers))
             \(reader.rows.map{row($0)}.joined(separator: "\n"))
             </table>
             <figcaption>Fig.1 - Trulli, Puglia, Italy.</figcaption>
             </figure>
             """
    }
    
  }
  
}

