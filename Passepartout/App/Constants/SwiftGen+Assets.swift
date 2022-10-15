// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Assets {
    internal static let accentColor = ColorAsset(name: "AccentColor")
    internal static let lightTextColor = ColorAsset(name: "LightTextColor")
    internal static let logo = ImageAsset(name: "Logo")
    internal static let primaryColor = ColorAsset(name: "PrimaryColor")
  }
  internal enum Flags {
    internal enum Flags {
      internal static let ad = ImageAsset(name: "flags/ad")
      internal static let ae = ImageAsset(name: "flags/ae")
      internal static let af = ImageAsset(name: "flags/af")
      internal static let ag = ImageAsset(name: "flags/ag")
      internal static let ai = ImageAsset(name: "flags/ai")
      internal static let al = ImageAsset(name: "flags/al")
      internal static let am = ImageAsset(name: "flags/am")
      internal static let ao = ImageAsset(name: "flags/ao")
      internal static let aq = ImageAsset(name: "flags/aq")
      internal static let ar = ImageAsset(name: "flags/ar")
      internal static let `as` = ImageAsset(name: "flags/as")
      internal static let at = ImageAsset(name: "flags/at")
      internal static let au = ImageAsset(name: "flags/au")
      internal static let aw = ImageAsset(name: "flags/aw")
      internal static let ax = ImageAsset(name: "flags/ax")
      internal static let az = ImageAsset(name: "flags/az")
      internal static let ba = ImageAsset(name: "flags/ba")
      internal static let bb = ImageAsset(name: "flags/bb")
      internal static let bd = ImageAsset(name: "flags/bd")
      internal static let be = ImageAsset(name: "flags/be")
      internal static let bf = ImageAsset(name: "flags/bf")
      internal static let bg = ImageAsset(name: "flags/bg")
      internal static let bh = ImageAsset(name: "flags/bh")
      internal static let bi = ImageAsset(name: "flags/bi")
      internal static let bj = ImageAsset(name: "flags/bj")
      internal static let bl = ImageAsset(name: "flags/bl")
      internal static let bm = ImageAsset(name: "flags/bm")
      internal static let bn = ImageAsset(name: "flags/bn")
      internal static let bo = ImageAsset(name: "flags/bo")
      internal static let bq = ImageAsset(name: "flags/bq")
      internal static let br = ImageAsset(name: "flags/br")
      internal static let bs = ImageAsset(name: "flags/bs")
      internal static let bt = ImageAsset(name: "flags/bt")
      internal static let bv = ImageAsset(name: "flags/bv")
      internal static let bw = ImageAsset(name: "flags/bw")
      internal static let by = ImageAsset(name: "flags/by")
      internal static let bz = ImageAsset(name: "flags/bz")
      internal static let ca = ImageAsset(name: "flags/ca")
      internal static let cc = ImageAsset(name: "flags/cc")
      internal static let cd = ImageAsset(name: "flags/cd")
      internal static let cf = ImageAsset(name: "flags/cf")
      internal static let cg = ImageAsset(name: "flags/cg")
      internal static let ch = ImageAsset(name: "flags/ch")
      internal static let ci = ImageAsset(name: "flags/ci")
      internal static let ck = ImageAsset(name: "flags/ck")
      internal static let cl = ImageAsset(name: "flags/cl")
      internal static let cm = ImageAsset(name: "flags/cm")
      internal static let cn = ImageAsset(name: "flags/cn")
      internal static let co = ImageAsset(name: "flags/co")
      internal static let cr = ImageAsset(name: "flags/cr")
      internal static let cu = ImageAsset(name: "flags/cu")
      internal static let cv = ImageAsset(name: "flags/cv")
      internal static let cw = ImageAsset(name: "flags/cw")
      internal static let cx = ImageAsset(name: "flags/cx")
      internal static let cy = ImageAsset(name: "flags/cy")
      internal static let cz = ImageAsset(name: "flags/cz")
      internal static let de = ImageAsset(name: "flags/de")
      internal static let dj = ImageAsset(name: "flags/dj")
      internal static let dk = ImageAsset(name: "flags/dk")
      internal static let dm = ImageAsset(name: "flags/dm")
      internal static let `do` = ImageAsset(name: "flags/do")
      internal static let dz = ImageAsset(name: "flags/dz")
      internal static let ec = ImageAsset(name: "flags/ec")
      internal static let ee = ImageAsset(name: "flags/ee")
      internal static let eg = ImageAsset(name: "flags/eg")
      internal static let eh = ImageAsset(name: "flags/eh")
      internal static let er = ImageAsset(name: "flags/er")
      internal static let esCt = ImageAsset(name: "flags/es-ct")
      internal static let es = ImageAsset(name: "flags/es")
      internal static let et = ImageAsset(name: "flags/et")
      internal static let eu = ImageAsset(name: "flags/eu")
      internal static let fi = ImageAsset(name: "flags/fi")
      internal static let fj = ImageAsset(name: "flags/fj")
      internal static let fk = ImageAsset(name: "flags/fk")
      internal static let fm = ImageAsset(name: "flags/fm")
      internal static let fo = ImageAsset(name: "flags/fo")
      internal static let fr = ImageAsset(name: "flags/fr")
      internal static let ga = ImageAsset(name: "flags/ga")
      internal static let gbEng = ImageAsset(name: "flags/gb-eng")
      internal static let gbNir = ImageAsset(name: "flags/gb-nir")
      internal static let gbSct = ImageAsset(name: "flags/gb-sct")
      internal static let gbWls = ImageAsset(name: "flags/gb-wls")
      internal static let gb = ImageAsset(name: "flags/gb")
      internal static let gd = ImageAsset(name: "flags/gd")
      internal static let ge = ImageAsset(name: "flags/ge")
      internal static let gf = ImageAsset(name: "flags/gf")
      internal static let gg = ImageAsset(name: "flags/gg")
      internal static let gh = ImageAsset(name: "flags/gh")
      internal static let gi = ImageAsset(name: "flags/gi")
      internal static let gl = ImageAsset(name: "flags/gl")
      internal static let gm = ImageAsset(name: "flags/gm")
      internal static let gn = ImageAsset(name: "flags/gn")
      internal static let gp = ImageAsset(name: "flags/gp")
      internal static let gq = ImageAsset(name: "flags/gq")
      internal static let gr = ImageAsset(name: "flags/gr")
      internal static let gs = ImageAsset(name: "flags/gs")
      internal static let gt = ImageAsset(name: "flags/gt")
      internal static let gu = ImageAsset(name: "flags/gu")
      internal static let gw = ImageAsset(name: "flags/gw")
      internal static let gy = ImageAsset(name: "flags/gy")
      internal static let hk = ImageAsset(name: "flags/hk")
      internal static let hm = ImageAsset(name: "flags/hm")
      internal static let hn = ImageAsset(name: "flags/hn")
      internal static let hr = ImageAsset(name: "flags/hr")
      internal static let ht = ImageAsset(name: "flags/ht")
      internal static let hu = ImageAsset(name: "flags/hu")
      internal static let id = ImageAsset(name: "flags/id")
      internal static let ie = ImageAsset(name: "flags/ie")
      internal static let il = ImageAsset(name: "flags/il")
      internal static let im = ImageAsset(name: "flags/im")
      internal static let `in` = ImageAsset(name: "flags/in")
      internal static let io = ImageAsset(name: "flags/io")
      internal static let iq = ImageAsset(name: "flags/iq")
      internal static let ir = ImageAsset(name: "flags/ir")
      internal static let `is` = ImageAsset(name: "flags/is")
      internal static let it = ImageAsset(name: "flags/it")
      internal static let je = ImageAsset(name: "flags/je")
      internal static let jm = ImageAsset(name: "flags/jm")
      internal static let jo = ImageAsset(name: "flags/jo")
      internal static let jp = ImageAsset(name: "flags/jp")
      internal static let ke = ImageAsset(name: "flags/ke")
      internal static let kg = ImageAsset(name: "flags/kg")
      internal static let kh = ImageAsset(name: "flags/kh")
      internal static let ki = ImageAsset(name: "flags/ki")
      internal static let km = ImageAsset(name: "flags/km")
      internal static let kn = ImageAsset(name: "flags/kn")
      internal static let kp = ImageAsset(name: "flags/kp")
      internal static let kr = ImageAsset(name: "flags/kr")
      internal static let kw = ImageAsset(name: "flags/kw")
      internal static let ky = ImageAsset(name: "flags/ky")
      internal static let kz = ImageAsset(name: "flags/kz")
      internal static let la = ImageAsset(name: "flags/la")
      internal static let lb = ImageAsset(name: "flags/lb")
      internal static let lc = ImageAsset(name: "flags/lc")
      internal static let li = ImageAsset(name: "flags/li")
      internal static let lk = ImageAsset(name: "flags/lk")
      internal static let lr = ImageAsset(name: "flags/lr")
      internal static let ls = ImageAsset(name: "flags/ls")
      internal static let lt = ImageAsset(name: "flags/lt")
      internal static let lu = ImageAsset(name: "flags/lu")
      internal static let lv = ImageAsset(name: "flags/lv")
      internal static let ly = ImageAsset(name: "flags/ly")
      internal static let ma = ImageAsset(name: "flags/ma")
      internal static let mc = ImageAsset(name: "flags/mc")
      internal static let md = ImageAsset(name: "flags/md")
      internal static let me = ImageAsset(name: "flags/me")
      internal static let mf = ImageAsset(name: "flags/mf")
      internal static let mg = ImageAsset(name: "flags/mg")
      internal static let mh = ImageAsset(name: "flags/mh")
      internal static let mk = ImageAsset(name: "flags/mk")
      internal static let ml = ImageAsset(name: "flags/ml")
      internal static let mm = ImageAsset(name: "flags/mm")
      internal static let mn = ImageAsset(name: "flags/mn")
      internal static let mo = ImageAsset(name: "flags/mo")
      internal static let mp = ImageAsset(name: "flags/mp")
      internal static let mq = ImageAsset(name: "flags/mq")
      internal static let mr = ImageAsset(name: "flags/mr")
      internal static let ms = ImageAsset(name: "flags/ms")
      internal static let mt = ImageAsset(name: "flags/mt")
      internal static let mu = ImageAsset(name: "flags/mu")
      internal static let mv = ImageAsset(name: "flags/mv")
      internal static let mw = ImageAsset(name: "flags/mw")
      internal static let mx = ImageAsset(name: "flags/mx")
      internal static let my = ImageAsset(name: "flags/my")
      internal static let mz = ImageAsset(name: "flags/mz")
      internal static let na = ImageAsset(name: "flags/na")
      internal static let nc = ImageAsset(name: "flags/nc")
      internal static let ne = ImageAsset(name: "flags/ne")
      internal static let nf = ImageAsset(name: "flags/nf")
      internal static let ng = ImageAsset(name: "flags/ng")
      internal static let ni = ImageAsset(name: "flags/ni")
      internal static let nl = ImageAsset(name: "flags/nl")
      internal static let no = ImageAsset(name: "flags/no")
      internal static let np = ImageAsset(name: "flags/np")
      internal static let nr = ImageAsset(name: "flags/nr")
      internal static let nu = ImageAsset(name: "flags/nu")
      internal static let nz = ImageAsset(name: "flags/nz")
      internal static let om = ImageAsset(name: "flags/om")
      internal static let pa = ImageAsset(name: "flags/pa")
      internal static let pe = ImageAsset(name: "flags/pe")
      internal static let pf = ImageAsset(name: "flags/pf")
      internal static let pg = ImageAsset(name: "flags/pg")
      internal static let ph = ImageAsset(name: "flags/ph")
      internal static let pk = ImageAsset(name: "flags/pk")
      internal static let pl = ImageAsset(name: "flags/pl")
      internal static let pm = ImageAsset(name: "flags/pm")
      internal static let pn = ImageAsset(name: "flags/pn")
      internal static let pr = ImageAsset(name: "flags/pr")
      internal static let ps = ImageAsset(name: "flags/ps")
      internal static let pt = ImageAsset(name: "flags/pt")
      internal static let pw = ImageAsset(name: "flags/pw")
      internal static let py = ImageAsset(name: "flags/py")
      internal static let qa = ImageAsset(name: "flags/qa")
      internal static let re = ImageAsset(name: "flags/re")
      internal static let ro = ImageAsset(name: "flags/ro")
      internal static let rs = ImageAsset(name: "flags/rs")
      internal static let ru = ImageAsset(name: "flags/ru")
      internal static let rw = ImageAsset(name: "flags/rw")
      internal static let sa = ImageAsset(name: "flags/sa")
      internal static let sb = ImageAsset(name: "flags/sb")
      internal static let sc = ImageAsset(name: "flags/sc")
      internal static let sd = ImageAsset(name: "flags/sd")
      internal static let se = ImageAsset(name: "flags/se")
      internal static let sg = ImageAsset(name: "flags/sg")
      internal static let sh = ImageAsset(name: "flags/sh")
      internal static let si = ImageAsset(name: "flags/si")
      internal static let sj = ImageAsset(name: "flags/sj")
      internal static let sk = ImageAsset(name: "flags/sk")
      internal static let sl = ImageAsset(name: "flags/sl")
      internal static let sm = ImageAsset(name: "flags/sm")
      internal static let sn = ImageAsset(name: "flags/sn")
      internal static let so = ImageAsset(name: "flags/so")
      internal static let sr = ImageAsset(name: "flags/sr")
      internal static let ss = ImageAsset(name: "flags/ss")
      internal static let st = ImageAsset(name: "flags/st")
      internal static let sv = ImageAsset(name: "flags/sv")
      internal static let sx = ImageAsset(name: "flags/sx")
      internal static let sy = ImageAsset(name: "flags/sy")
      internal static let sz = ImageAsset(name: "flags/sz")
      internal static let tc = ImageAsset(name: "flags/tc")
      internal static let td = ImageAsset(name: "flags/td")
      internal static let tf = ImageAsset(name: "flags/tf")
      internal static let tg = ImageAsset(name: "flags/tg")
      internal static let th = ImageAsset(name: "flags/th")
      internal static let tj = ImageAsset(name: "flags/tj")
      internal static let tk = ImageAsset(name: "flags/tk")
      internal static let tl = ImageAsset(name: "flags/tl")
      internal static let tm = ImageAsset(name: "flags/tm")
      internal static let tn = ImageAsset(name: "flags/tn")
      internal static let to = ImageAsset(name: "flags/to")
      internal static let tr = ImageAsset(name: "flags/tr")
      internal static let tt = ImageAsset(name: "flags/tt")
      internal static let tv = ImageAsset(name: "flags/tv")
      internal static let tw = ImageAsset(name: "flags/tw")
      internal static let tz = ImageAsset(name: "flags/tz")
      internal static let ua = ImageAsset(name: "flags/ua")
      internal static let ug = ImageAsset(name: "flags/ug")
      internal static let um = ImageAsset(name: "flags/um")
      internal static let un = ImageAsset(name: "flags/un")
      internal static let us = ImageAsset(name: "flags/us")
      internal static let uy = ImageAsset(name: "flags/uy")
      internal static let uz = ImageAsset(name: "flags/uz")
      internal static let va = ImageAsset(name: "flags/va")
      internal static let vc = ImageAsset(name: "flags/vc")
      internal static let ve = ImageAsset(name: "flags/ve")
      internal static let vg = ImageAsset(name: "flags/vg")
      internal static let vi = ImageAsset(name: "flags/vi")
      internal static let vn = ImageAsset(name: "flags/vn")
      internal static let vu = ImageAsset(name: "flags/vu")
      internal static let wf = ImageAsset(name: "flags/wf")
      internal static let ws = ImageAsset(name: "flags/ws")
      internal static let xk = ImageAsset(name: "flags/xk")
      internal static let ye = ImageAsset(name: "flags/ye")
      internal static let yt = ImageAsset(name: "flags/yt")
      internal static let za = ImageAsset(name: "flags/za")
      internal static let zm = ImageAsset(name: "flags/zm")
      internal static let zw = ImageAsset(name: "flags/zw")
    }
  }
  internal enum Providers {
    internal enum Providers {
      internal static let hideme = ImageAsset(name: "providers/hideme")
      internal static let ivpn = ImageAsset(name: "providers/ivpn")
      internal static let mullvad = ImageAsset(name: "providers/mullvad")
      internal static let nordvpn = ImageAsset(name: "providers/nordvpn")
      internal static let oeck = ImageAsset(name: "providers/oeck")
      internal static let pia = ImageAsset(name: "providers/pia")
      internal static let placeholder = ImageAsset(name: "providers/placeholder")
      internal static let protonvpn = ImageAsset(name: "providers/protonvpn")
      internal static let surfshark = ImageAsset(name: "providers/surfshark")
      internal static let torguard = ImageAsset(name: "providers/torguard")
      internal static let tunnelbear = ImageAsset(name: "providers/tunnelbear")
      internal static let vyprvpn = ImageAsset(name: "providers/vyprvpn")
      internal static let windscribe = ImageAsset(name: "providers/windscribe")
    }
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = Color(asset: self)

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init!(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
