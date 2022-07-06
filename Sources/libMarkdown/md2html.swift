//
//  File.swift
//  
//
//  Created by psksvp on 4/7/2022.
//

import Foundation
import lowdown

public func md2html(_ md: String) -> String
{
  var opt = lowdown_opts()
  
  opt.type = LOWDOWN_HTML
  opt.feat = UInt32(LOWDOWN_FOOTNOTES |
                    LOWDOWN_AUTOLINK |
                    LOWDOWN_TABLES |
                    LOWDOWN_SUPER |
                    LOWDOWN_STRIKE |
                    LOWDOWN_FENCED |
                    LOWDOWN_COMMONMARK |
                    LOWDOWN_DEFLIST |
                    LOWDOWN_IMG_EXT |
                    LOWDOWN_METADATA)

  opt.oflags = UInt32(LOWDOWN_HTML_HEAD_IDS |
                      LOWDOWN_HTML_NUM_ENT |
                      LOWDOWN_HTML_OWASP |
                      LOWDOWN_SMARTY |
                      LOWDOWN_STANDALONE)
  
  var obuf: UnsafeMutablePointer<CChar>? = nil // &obuf becomes char**
  var osize:Int = 0
  
  let _ = lowdown_buf(&opt, md, md.utf8.count, &obuf, &osize, nil)
  if let out = obuf
  {
    defer {obuf?.deallocate()}
    let d = Data(bytes: out, count: osize)
    return String(decoding: d, as: UTF8.self)
  }
  return ""
}
