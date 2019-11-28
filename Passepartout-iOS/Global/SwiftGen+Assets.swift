// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSImage
  internal typealias AssetColorTypeAlias = NSColor
  internal typealias AssetImageTypeAlias = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  internal typealias AssetColorTypeAlias = UIColor
  internal typealias AssetImageTypeAlias = UIImage
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Assets {
    internal static let logo = ImageAsset(name: "logo")
  }
  internal enum Flags {
    internal static let ad = ImageAsset(name: "ad")
    internal static let ae = ImageAsset(name: "ae")
    internal static let af = ImageAsset(name: "af")
    internal static let ag = ImageAsset(name: "ag")
    internal static let ai = ImageAsset(name: "ai")
    internal static let al = ImageAsset(name: "al")
    internal static let am = ImageAsset(name: "am")
    internal static let ao = ImageAsset(name: "ao")
    internal static let aq = ImageAsset(name: "aq")
    internal static let ar = ImageAsset(name: "ar")
    internal static let `as` = ImageAsset(name: "as")
    internal static let at = ImageAsset(name: "at")
    internal static let au = ImageAsset(name: "au")
    internal static let aw = ImageAsset(name: "aw")
    internal static let ax = ImageAsset(name: "ax")
    internal static let az = ImageAsset(name: "az")
    internal static let ba = ImageAsset(name: "ba")
    internal static let bb = ImageAsset(name: "bb")
    internal static let bd = ImageAsset(name: "bd")
    internal static let be = ImageAsset(name: "be")
    internal static let bf = ImageAsset(name: "bf")
    internal static let bg = ImageAsset(name: "bg")
    internal static let bh = ImageAsset(name: "bh")
    internal static let bi = ImageAsset(name: "bi")
    internal static let bj = ImageAsset(name: "bj")
    internal static let bl = ImageAsset(name: "bl")
    internal static let bm = ImageAsset(name: "bm")
    internal static let bn = ImageAsset(name: "bn")
    internal static let bo = ImageAsset(name: "bo")
    internal static let bq = ImageAsset(name: "bq")
    internal static let br = ImageAsset(name: "br")
    internal static let bs = ImageAsset(name: "bs")
    internal static let bt = ImageAsset(name: "bt")
    internal static let bv = ImageAsset(name: "bv")
    internal static let bw = ImageAsset(name: "bw")
    internal static let by = ImageAsset(name: "by")
    internal static let bz = ImageAsset(name: "bz")
    internal static let ca = ImageAsset(name: "ca")
    internal static let cc = ImageAsset(name: "cc")
    internal static let cd = ImageAsset(name: "cd")
    internal static let cf = ImageAsset(name: "cf")
    internal static let cg = ImageAsset(name: "cg")
    internal static let ch = ImageAsset(name: "ch")
    internal static let ci = ImageAsset(name: "ci")
    internal static let ck = ImageAsset(name: "ck")
    internal static let cl = ImageAsset(name: "cl")
    internal static let cm = ImageAsset(name: "cm")
    internal static let cn = ImageAsset(name: "cn")
    internal static let co = ImageAsset(name: "co")
    internal static let cr = ImageAsset(name: "cr")
    internal static let cu = ImageAsset(name: "cu")
    internal static let cv = ImageAsset(name: "cv")
    internal static let cw = ImageAsset(name: "cw")
    internal static let cx = ImageAsset(name: "cx")
    internal static let cy = ImageAsset(name: "cy")
    internal static let cz = ImageAsset(name: "cz")
    internal static let de = ImageAsset(name: "de")
    internal static let dj = ImageAsset(name: "dj")
    internal static let dk = ImageAsset(name: "dk")
    internal static let dm = ImageAsset(name: "dm")
    internal static let `do` = ImageAsset(name: "do")
    internal static let dz = ImageAsset(name: "dz")
    internal static let ec = ImageAsset(name: "ec")
    internal static let ee = ImageAsset(name: "ee")
    internal static let eg = ImageAsset(name: "eg")
    internal static let eh = ImageAsset(name: "eh")
    internal static let er = ImageAsset(name: "er")
    internal static let esCt = ImageAsset(name: "es-ct")
    internal static let es = ImageAsset(name: "es")
    internal static let et = ImageAsset(name: "et")
    internal static let eu = ImageAsset(name: "eu")
    internal static let fi = ImageAsset(name: "fi")
    internal static let fj = ImageAsset(name: "fj")
    internal static let fk = ImageAsset(name: "fk")
    internal static let fm = ImageAsset(name: "fm")
    internal static let fo = ImageAsset(name: "fo")
    internal static let fr = ImageAsset(name: "fr")
    internal static let ga = ImageAsset(name: "ga")
    internal static let gbEng = ImageAsset(name: "gb-eng")
    internal static let gbNir = ImageAsset(name: "gb-nir")
    internal static let gbSct = ImageAsset(name: "gb-sct")
    internal static let gbWls = ImageAsset(name: "gb-wls")
    internal static let gb = ImageAsset(name: "gb")
    internal static let gd = ImageAsset(name: "gd")
    internal static let ge = ImageAsset(name: "ge")
    internal static let gf = ImageAsset(name: "gf")
    internal static let gg = ImageAsset(name: "gg")
    internal static let gh = ImageAsset(name: "gh")
    internal static let gi = ImageAsset(name: "gi")
    internal static let gl = ImageAsset(name: "gl")
    internal static let gm = ImageAsset(name: "gm")
    internal static let gn = ImageAsset(name: "gn")
    internal static let gp = ImageAsset(name: "gp")
    internal static let gq = ImageAsset(name: "gq")
    internal static let gr = ImageAsset(name: "gr")
    internal static let gs = ImageAsset(name: "gs")
    internal static let gt = ImageAsset(name: "gt")
    internal static let gu = ImageAsset(name: "gu")
    internal static let gw = ImageAsset(name: "gw")
    internal static let gy = ImageAsset(name: "gy")
    internal static let hk = ImageAsset(name: "hk")
    internal static let hm = ImageAsset(name: "hm")
    internal static let hn = ImageAsset(name: "hn")
    internal static let hr = ImageAsset(name: "hr")
    internal static let ht = ImageAsset(name: "ht")
    internal static let hu = ImageAsset(name: "hu")
    internal static let id = ImageAsset(name: "id")
    internal static let ie = ImageAsset(name: "ie")
    internal static let il = ImageAsset(name: "il")
    internal static let im = ImageAsset(name: "im")
    internal static let `in` = ImageAsset(name: "in")
    internal static let io = ImageAsset(name: "io")
    internal static let iq = ImageAsset(name: "iq")
    internal static let ir = ImageAsset(name: "ir")
    internal static let `is` = ImageAsset(name: "is")
    internal static let it = ImageAsset(name: "it")
    internal static let je = ImageAsset(name: "je")
    internal static let jm = ImageAsset(name: "jm")
    internal static let jo = ImageAsset(name: "jo")
    internal static let jp = ImageAsset(name: "jp")
    internal static let ke = ImageAsset(name: "ke")
    internal static let kg = ImageAsset(name: "kg")
    internal static let kh = ImageAsset(name: "kh")
    internal static let ki = ImageAsset(name: "ki")
    internal static let km = ImageAsset(name: "km")
    internal static let kn = ImageAsset(name: "kn")
    internal static let kp = ImageAsset(name: "kp")
    internal static let kr = ImageAsset(name: "kr")
    internal static let kw = ImageAsset(name: "kw")
    internal static let ky = ImageAsset(name: "ky")
    internal static let kz = ImageAsset(name: "kz")
    internal static let la = ImageAsset(name: "la")
    internal static let lb = ImageAsset(name: "lb")
    internal static let lc = ImageAsset(name: "lc")
    internal static let li = ImageAsset(name: "li")
    internal static let lk = ImageAsset(name: "lk")
    internal static let lr = ImageAsset(name: "lr")
    internal static let ls = ImageAsset(name: "ls")
    internal static let lt = ImageAsset(name: "lt")
    internal static let lu = ImageAsset(name: "lu")
    internal static let lv = ImageAsset(name: "lv")
    internal static let ly = ImageAsset(name: "ly")
    internal static let ma = ImageAsset(name: "ma")
    internal static let mc = ImageAsset(name: "mc")
    internal static let md = ImageAsset(name: "md")
    internal static let me = ImageAsset(name: "me")
    internal static let mf = ImageAsset(name: "mf")
    internal static let mg = ImageAsset(name: "mg")
    internal static let mh = ImageAsset(name: "mh")
    internal static let mk = ImageAsset(name: "mk")
    internal static let ml = ImageAsset(name: "ml")
    internal static let mm = ImageAsset(name: "mm")
    internal static let mn = ImageAsset(name: "mn")
    internal static let mo = ImageAsset(name: "mo")
    internal static let mp = ImageAsset(name: "mp")
    internal static let mq = ImageAsset(name: "mq")
    internal static let mr = ImageAsset(name: "mr")
    internal static let ms = ImageAsset(name: "ms")
    internal static let mt = ImageAsset(name: "mt")
    internal static let mu = ImageAsset(name: "mu")
    internal static let mv = ImageAsset(name: "mv")
    internal static let mw = ImageAsset(name: "mw")
    internal static let mx = ImageAsset(name: "mx")
    internal static let my = ImageAsset(name: "my")
    internal static let mz = ImageAsset(name: "mz")
    internal static let na = ImageAsset(name: "na")
    internal static let nc = ImageAsset(name: "nc")
    internal static let ne = ImageAsset(name: "ne")
    internal static let nf = ImageAsset(name: "nf")
    internal static let ng = ImageAsset(name: "ng")
    internal static let ni = ImageAsset(name: "ni")
    internal static let nl = ImageAsset(name: "nl")
    internal static let no = ImageAsset(name: "no")
    internal static let np = ImageAsset(name: "np")
    internal static let nr = ImageAsset(name: "nr")
    internal static let nu = ImageAsset(name: "nu")
    internal static let nz = ImageAsset(name: "nz")
    internal static let om = ImageAsset(name: "om")
    internal static let pa = ImageAsset(name: "pa")
    internal static let pe = ImageAsset(name: "pe")
    internal static let pf = ImageAsset(name: "pf")
    internal static let pg = ImageAsset(name: "pg")
    internal static let ph = ImageAsset(name: "ph")
    internal static let pk = ImageAsset(name: "pk")
    internal static let pl = ImageAsset(name: "pl")
    internal static let pm = ImageAsset(name: "pm")
    internal static let pn = ImageAsset(name: "pn")
    internal static let pr = ImageAsset(name: "pr")
    internal static let ps = ImageAsset(name: "ps")
    internal static let pt = ImageAsset(name: "pt")
    internal static let pw = ImageAsset(name: "pw")
    internal static let py = ImageAsset(name: "py")
    internal static let qa = ImageAsset(name: "qa")
    internal static let re = ImageAsset(name: "re")
    internal static let ro = ImageAsset(name: "ro")
    internal static let rs = ImageAsset(name: "rs")
    internal static let ru = ImageAsset(name: "ru")
    internal static let rw = ImageAsset(name: "rw")
    internal static let sa = ImageAsset(name: "sa")
    internal static let sb = ImageAsset(name: "sb")
    internal static let sc = ImageAsset(name: "sc")
    internal static let sd = ImageAsset(name: "sd")
    internal static let se = ImageAsset(name: "se")
    internal static let sg = ImageAsset(name: "sg")
    internal static let sh = ImageAsset(name: "sh")
    internal static let si = ImageAsset(name: "si")
    internal static let sj = ImageAsset(name: "sj")
    internal static let sk = ImageAsset(name: "sk")
    internal static let sl = ImageAsset(name: "sl")
    internal static let sm = ImageAsset(name: "sm")
    internal static let sn = ImageAsset(name: "sn")
    internal static let so = ImageAsset(name: "so")
    internal static let sr = ImageAsset(name: "sr")
    internal static let ss = ImageAsset(name: "ss")
    internal static let st = ImageAsset(name: "st")
    internal static let sv = ImageAsset(name: "sv")
    internal static let sx = ImageAsset(name: "sx")
    internal static let sy = ImageAsset(name: "sy")
    internal static let sz = ImageAsset(name: "sz")
    internal static let tc = ImageAsset(name: "tc")
    internal static let td = ImageAsset(name: "td")
    internal static let tf = ImageAsset(name: "tf")
    internal static let tg = ImageAsset(name: "tg")
    internal static let th = ImageAsset(name: "th")
    internal static let tj = ImageAsset(name: "tj")
    internal static let tk = ImageAsset(name: "tk")
    internal static let tl = ImageAsset(name: "tl")
    internal static let tm = ImageAsset(name: "tm")
    internal static let tn = ImageAsset(name: "tn")
    internal static let to = ImageAsset(name: "to")
    internal static let tr = ImageAsset(name: "tr")
    internal static let tt = ImageAsset(name: "tt")
    internal static let tv = ImageAsset(name: "tv")
    internal static let tw = ImageAsset(name: "tw")
    internal static let tz = ImageAsset(name: "tz")
    internal static let ua = ImageAsset(name: "ua")
    internal static let ug = ImageAsset(name: "ug")
    internal static let um = ImageAsset(name: "um")
    internal static let un = ImageAsset(name: "un")
    internal static let us = ImageAsset(name: "us")
    internal static let uy = ImageAsset(name: "uy")
    internal static let uz = ImageAsset(name: "uz")
    internal static let va = ImageAsset(name: "va")
    internal static let vc = ImageAsset(name: "vc")
    internal static let ve = ImageAsset(name: "ve")
    internal static let vg = ImageAsset(name: "vg")
    internal static let vi = ImageAsset(name: "vi")
    internal static let vn = ImageAsset(name: "vn")
    internal static let vu = ImageAsset(name: "vu")
    internal static let wf = ImageAsset(name: "wf")
    internal static let ws = ImageAsset(name: "ws")
    internal static let xk = ImageAsset(name: "xk")
    internal static let ye = ImageAsset(name: "ye")
    internal static let yt = ImageAsset(name: "yt")
    internal static let za = ImageAsset(name: "za")
    internal static let zm = ImageAsset(name: "zm")
    internal static let zw = ImageAsset(name: "zw")
  }
  internal enum Providers {
    internal static let mullvad = ImageAsset(name: "mullvad")
    internal static let nordvpn = ImageAsset(name: "nordvpn")
    internal static let pia = ImageAsset(name: "pia")
    internal static let placeholder = ImageAsset(name: "placeholder")
    internal static let protonvpn = ImageAsset(name: "protonvpn")
    internal static let tunnelbear = ImageAsset(name: "tunnelbear")
    internal static let vyprvpn = ImageAsset(name: "vyprvpn")
    internal static let windscribe = ImageAsset(name: "windscribe")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ColorAsset {
  internal fileprivate(set) var name: String

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  internal var color: AssetColorTypeAlias {
    return AssetColorTypeAlias(asset: self)
  }
}

internal extension AssetColorTypeAlias {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  convenience init!(asset: ColorAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct DataAsset {
  internal fileprivate(set) var name: String

  #if os(iOS) || os(tvOS) || os(OSX)
  @available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
  internal var data: NSDataAsset {
    return NSDataAsset(asset: self)
  }
  #endif
}

#if os(iOS) || os(tvOS) || os(OSX)
@available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
internal extension NSDataAsset {
  convenience init!(asset: DataAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(name: asset.name, bundle: bundle)
    #elseif os(OSX)
    self.init(name: NSDataAsset.Name(asset.name), bundle: bundle)
    #endif
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  internal var image: AssetImageTypeAlias {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    let image = AssetImageTypeAlias(named: name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = AssetImageTypeAlias(named: name)
    #endif
    guard let result = image else { fatalError("Unable to load image named \(name).") }
    return result
  }
}

internal extension AssetImageTypeAlias {
  @available(iOS 1.0, tvOS 1.0, watchOS 1.0, *)
  @available(OSX, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle(for: BundleToken.self)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

private final class BundleToken {}
