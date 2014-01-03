# encoding: CP949
#
#This is an implementation of wcwidth() and wcswidth() (defined in
#IEEE Std 1002.1-2001) for Unicode.
#
#http://www.opengroup.org/onlinepubs/007904975/functions/wcwidth.html
#http://www.opengroup.org/onlinepubs/007904975/functions/wcswidth.html
#
#Markus Kuhn -- 2007-05-26 (Unicode 5.0)
#
#Permission to use, copy, modify, and distribute this software
#for any purpose and without fee is hereby granted. The author
#disclaims all warranties with regard to this software.
#
#Latest version: http://www.cl.cam.ac.uk/~mgk25/ucs/wcwidth.c
#

# Changes made for mutt:
# - Adapted for Mutt by Edmund Grimley Evans.
# - Changed 'first'/'last' members of combined[] to wchar_t from
#   unsigned short to fix compiler warnings, 2007-11-13, Rocco Rutte
# 
# Translated from https://github.com/fumiyas/wcwidth-cjk/
# Copyright (c) 2013 SATOH Fumiyasu @ OSS Technology Corp., Japan

class String
  # sorted list of non-overlapping intervals of non-spacing characters 
  Combining = 
   [0x0300..0x036f, 0x0483..0x0486, 0x0488..0x0489,
    0x0591..0x05bd, 0x05bf..0x05bf, 0x05c1..0x05c2,
    0x05c4..0x05c5, 0x05c7..0x05c7, 0x0600..0x0603,
    0x0610..0x0615, 0x064b..0x065e, 0x0670..0x0670,
    0x06d6..0x06e4, 0x06e7..0x06e8, 0x06ea..0x06ed,
    0x070f..0x070f, 0x0711..0x0711, 0x0730..0x074a,
    0x07a6..0x07b0, 0x07eb..0x07f3, 0x0901..0x0902,
    0x093c..0x093c, 0x0941..0x0948, 0x094d..0x094d,
    0x0951..0x0954, 0x0962..0x0963, 0x0981..0x0981,
    0x09bc..0x09bc, 0x09c1..0x09c4, 0x09cd..0x09cd,
    0x09e2..0x09e3, 0x0a01..0x0a02, 0x0a3c..0x0a3c,
    0x0a41..0x0a42, 0x0a47..0x0a48, 0x0a4b..0x0a4d,
    0x0a70..0x0a71, 0x0a81..0x0a82, 0x0abc..0x0abc,
    0x0ac1..0x0ac5, 0x0ac7..0x0ac8, 0x0acd..0x0acd,
    0x0ae2..0x0ae3, 0x0b01..0x0b01, 0x0b3c..0x0b3c,
    0x0b3f..0x0b3f, 0x0b41..0x0b43, 0x0b4d..0x0b4d,
    0x0b56..0x0b56, 0x0b82..0x0b82, 0x0bc0..0x0bc0,
    0x0bcd..0x0bcd, 0x0c3e..0x0c40, 0x0c46..0x0c48,
    0x0c4a..0x0c4d, 0x0c55..0x0c56, 0x0cbc..0x0cbc,
    0x0cbf..0x0cbf, 0x0cc6..0x0cc6, 0x0ccc..0x0ccd,
    0x0ce2..0x0ce3, 0x0d41..0x0d43, 0x0d4d..0x0d4d,
    0x0dca..0x0dca, 0x0dd2..0x0dd4, 0x0dd6..0x0dd6,
    0x0e31..0x0e31, 0x0e34..0x0e3a, 0x0e47..0x0e4e,
    0x0eb1..0x0eb1, 0x0eb4..0x0eb9, 0x0ebb..0x0ebc,
    0x0ec8..0x0ecd, 0x0f18..0x0f19, 0x0f35..0x0f35,
    0x0f37..0x0f37, 0x0f39..0x0f39, 0x0f71..0x0f7e,
    0x0f80..0x0f84, 0x0f86..0x0f87, 0x0f90..0x0f97,
    0x0f99..0x0fbc, 0x0fc6..0x0fc6, 0x102d..0x1030,
    0x1032..0x1032, 0x1036..0x1037, 0x1039..0x1039,
    0x1058..0x1059, 0x1160..0x11ff, 0x135f..0x135f,
    0x1712..0x1714, 0x1732..0x1734, 0x1752..0x1753,
    0x1772..0x1773, 0x17b4..0x17b5, 0x17b7..0x17bd,
    0x17c6..0x17c6, 0x17c9..0x17d3, 0x17dd..0x17dd,
    0x180b..0x180d, 0x18a9..0x18a9, 0x1920..0x1922,
    0x1927..0x1928, 0x1932..0x1932, 0x1939..0x193b,
    0x1a17..0x1a18, 0x1b00..0x1b03, 0x1b34..0x1b34,
    0x1b36..0x1b3a, 0x1b3c..0x1b3c, 0x1b42..0x1b42,
    0x1b6b..0x1b73, 0x1dc0..0x1dca, 0x1dfe..0x1dff,
    0x200b..0x200f, 0x202a..0x202e, 0x2060..0x2063,
    0x206a..0x206f, 0x20d0..0x20ef, 0x302a..0x302f,
    0x3099..0x309a, 0xa806..0xa806, 0xa80b..0xa80b,
    0xa825..0xa826, 0xfb1e..0xfb1e, 0xfe00..0xfe0f,
    0xfe20..0xfe23, 0xfeff..0xfeff, 0xfff9..0xfffb,
    0x10a01..0x10a03, 0x10a05..0x10a06, 0x10a0c..0x10a0f,
    0x10a38..0x10a3a, 0x10a3f..0x10a3f, 0x1d167..0x1d169,
    0x1d173..0x1d182, 0x1d185..0x1d18b, 0x1d1aa..0x1d1ad,
    0x1d242..0x1d244, 0xe0001..0xe0001, 0xe0020..0xe007f,
    0xe0100..0xe01ef].map{|x|x.to_a}.flatten

  # sorted list of non-overlapping intervals of East Asian Ambiguous
  Ambiguous = 
   [0x00a1..0x00a1, 0x00a4..0x00a4, 0x00a7..0x00a8,
    0x00aa..0x00aa, 0x00ae..0x00ae, 0x00b0..0x00b4,
    0x00b6..0x00ba, 0x00bc..0x00bf, 0x00c6..0x00c6,
    0x00d0..0x00d0, 0x00d7..0x00d8, 0x00de..0x00e1,
    0x00e6..0x00e6, 0x00e8..0x00ea, 0x00ec..0x00ed,
    0x00f0..0x00f0, 0x00f2..0x00f3, 0x00f7..0x00fa,
    0x00fc..0x00fc, 0x00fe..0x00fe, 0x0101..0x0101,
    0x0111..0x0111, 0x0113..0x0113, 0x011b..0x011b,
    0x0126..0x0127, 0x012b..0x012b, 0x0131..0x0133,
    0x0138..0x0138, 0x013f..0x0142, 0x0144..0x0144,
    0x0148..0x014b, 0x014d..0x014d, 0x0152..0x0153,
    0x0166..0x0167, 0x016b..0x016b, 0x01ce..0x01ce,
    0x01d0..0x01d0, 0x01d2..0x01d2, 0x01d4..0x01d4,
    0x01d6..0x01d6, 0x01d8..0x01d8, 0x01da..0x01da,
    0x01dc..0x01dc, 0x0251..0x0251, 0x0261..0x0261,
    0x02c4..0x02c4, 0x02c7..0x02c7, 0x02c9..0x02cb,
    0x02cd..0x02cd, 0x02d0..0x02d0, 0x02d8..0x02db,
    0x02dd..0x02dd, 0x02df..0x02df, 0x0391..0x03a1,
    0x03a3..0x03a9, 0x03b1..0x03c1, 0x03c3..0x03c9,
    0x0401..0x0401, 0x0410..0x044f, 0x0451..0x0451,
    0x2010..0x2010, 0x2013..0x2016, 0x2018..0x2019,
    0x201c..0x201d, 0x2020..0x2022, 0x2024..0x2027,
    0x2030..0x2030, 0x2032..0x2033, 0x2035..0x2035,
    0x203b..0x203b, 0x203e..0x203e, 0x2074..0x2074,
    0x207f..0x207f, 0x2081..0x2084, 0x20ac..0x20ac,
    0x2103..0x2103, 0x2105..0x2105, 0x2109..0x2109,
    0x2113..0x2113, 0x2116..0x2116, 0x2121..0x2122,
    0x2126..0x2126, 0x212b..0x212b, 0x2153..0x2154,
    0x215b..0x215e, 0x2160..0x216b, 0x2170..0x2179,
    0x2190..0x2199, 0x21b8..0x21b9, 0x21d2..0x21d2,
    0x21d4..0x21d4, 0x21e7..0x21e7, 0x2200..0x2200,
    0x2202..0x2203, 0x2207..0x2208, 0x220b..0x220b,
    0x220f..0x220f, 0x2211..0x2211, 0x2215..0x2215,
    0x221a..0x221a, 0x221d..0x2220, 0x2223..0x2223,
    0x2225..0x2225, 0x2227..0x222c, 0x222e..0x222e,
    0x2234..0x2237, 0x223c..0x223d, 0x2248..0x2248,
    0x224c..0x224c, 0x2252..0x2252, 0x2260..0x2261,
    0x2264..0x2267, 0x226a..0x226b, 0x226e..0x226f,
    0x2282..0x2283, 0x2286..0x2287, 0x2295..0x2295,
    0x2299..0x2299, 0x22a5..0x22a5, 0x22bf..0x22bf,
    0x2312..0x2312, 0x2460..0x24e9, 0x24eb..0x254b,
    0x2550..0x2573, 0x2580..0x258f, 0x2592..0x2595,
    0x25a0..0x25a1, 0x25a3..0x25a9, 0x25b2..0x25b3,
    0x25b6..0x25b7, 0x25bc..0x25bd, 0x25c0..0x25c1,
    0x25c6..0x25c8, 0x25cb..0x25cb, 0x25ce..0x25d1,
    0x25e2..0x25e5, 0x25ef..0x25ef, 0x2605..0x2606,
    0x2609..0x2609, 0x260e..0x260f, 0x2614..0x2615,
    0x261c..0x261c, 0x261e..0x261e, 0x2640..0x2640,
    0x2642..0x2642, 0x2660..0x2661, 0x2663..0x2665,
    0x2667..0x266a, 0x266c..0x266d, 0x266f..0x266f,
    0x273d..0x273d, 0x2776..0x277f, 0xe000..0xf8ff,
    0xfffd..0xfffd, 0xf0000..0xffffd, 0x100000..0x10fffd].map{|x|x.to_a}.flatten 
    
  # For Japanese legacy encodings, the following characters are added. 
  Legacy_ja =
    [0x00A2..0x00A3, 0x00A5..0x00A6, 0x00AC..0x00AC,
     0x00AF..0x00AF, 0x2212..0x2212].map{|x|x.to_a}.flatten 
    
protected
  # The following two functions define the column width of an ISO 10646
  # character as follows:
  #
  #    - The null character (U+0000) has a column width of 0.
  #
  #    - Other C0/C1 control characters and DEL will lead to a return
  #      value of -1.
  #
  #    - Non-spacing and enclosing combining characters (general
  #      category code Mn or Me in the Unicode database) have a
  #      column width of 0.
  #
  #    - SOFT HYPHEN (U+00AD) has a column width of 1.
  #
  #    - Other format characters (general category code Cf in the Unicode
  #      database) and ZERO WIDTH SPACE (U+200B) have a column width of 0.
  #
  #    - Hangul Jamo medial vowels and final consonants (U+1160-U+11FF)
  #      have a column width of 0.
  #
  #    - Spacing characters in the East Asian Wide (W) or East Asian
  #      Full-width (F) category as defined in Unicode Technical
  #      Report #11 have a column width of 2.
  #
  #    - All remaining characters (including all printable
  #      ISO 8859-1 and WGL4 characters, Unicode control characters,
  #      etc.) have a column width of 1.
  #
  # This implementation assumes that ucs characters are encoded
  # in ISO 10646.
  #
  def wcwidth_ucs(ucs)
    return 0 if ucs == 0

    return -1 if ucs < 32 || (ucs >= 0x7f && ucs < 0xa0)

    return 0 if Combining.include?(ucs)

    # if we arrive here, ucs is not a combining or C0/C1 control character 

    # fast test for majority of non-wide scripts 
    return 1 if ucs < 0x1100
    
    (ucs >= 0x1100 &&                      # Hangul Jamu init. consonants
     (ucs <= 0x115f ||
     ucs == 0x2329 || ucs == 0x232a ||
     (ucs >= 0x2e80 && ucs <= 0xa4cf &&
      ucs != 0x303f) ||                    # CJK ... Yi
     (ucs >= 0xac00 && ucs <= 0xd7a3) ||   # Hangul Syllables
     (ucs >= 0xf900 && ucs <= 0xfaff) ||   # CJK Compatibility Ideographs
     (ucs >= 0xfe10 && ucs <= 0xfe19) ||   # Vertical forms
     (ucs >= 0xfe30 && ucs <= 0xfe6f) ||   # CJK Compatibility Forms
     (ucs >= 0xff00 && ucs <= 0xff60) ||   # Fullwidth Forms
     (ucs >= 0xffe0 && ucs <= 0xffe6) ||
     (ucs >= 0x20000 && ucs <= 0x2fffd) ||
     (ucs >= 0x30000 && ucs <= 0x3fffd))) ? 2 : 1
  end
  
  # The following functions are the same as wcwidth_ucs() and
  # wcwidth_cjk(), except that spacing characters in the East Asian
  # Ambiguous (A) category as defined in Unicode Technical Report #11
  # have a column width of 2. This variant might be useful for users of
  # CJK legacy encodings who want to migrate to UCS without changing
  # the traditional terminal character-width behaviour. It is not
  # otherwise recommended for general use.
  #
  #
  # In addition to the explanation mentioned above,
  # several characters in the East Asian Narrow (Na) and Not East Asian
  # (Neutral) category as defined in Unicode Technical Report #11
  # actually have a column width of 2 in CJK legacy encodings.
  #  
  def wcwidth_cjk(ucs)
    return 0 if ucs == 0    
    
    return 2 if Ambiguous.include?(ucs) || Legacy_ja.include?(ucs)

    wcwidth_ucs(ucs)
  end
  

  def mk_wcswidth(ucs)
    ws = self.each_char.map(&:width)
    return -1 unless ws.all?{|x|x>=0}
    ws.inject(:+)
  end

public

  def wcwidth
    return 0 if self.size == 0
    if self.encoding==Encoding::UTF_8    
      str = self
    else
      str = self.encode('UTF-8')
    end
    
    wcwidth_cjk(str.ord)
  end
  
  def wcswidth
    return 0 if self.size == 0
    if self.encoding==Encoding::UTF_8    
      str = self
    else
      str = self.encode('UTF-8')
    end
    
    str.codepoints.map{|x|wcwidth_cjk(x)}.inject(:+)
  end

end
