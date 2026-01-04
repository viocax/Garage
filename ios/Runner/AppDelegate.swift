import Flutter
import UIKit
import google_mobile_ads

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Register NativeAdFactory
    let factory = NativeAdFactory()
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(self, factoryId: "listTile", nativeAdFactory: factory)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

class NativeAdFactory: NSObject, FLTNativeAdFactory {
    func createNativeAd(_ nativeAd: NativeAd, customOptions: [AnyHashable : Any]? = nil) -> NativeAdView? {
        let garageNativeAdView = GarageNativeAdView()
        
        (garageNativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        garageNativeAdView.headlineView?.isHidden = nativeAd.headline == nil
        
        (garageNativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        garageNativeAdView.bodyView?.isHidden = nativeAd.body == nil
        
        (garageNativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        garageNativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
        
        (garageNativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        garageNativeAdView.iconView?.isHidden = nativeAd.icon == nil
        
        garageNativeAdView.nativeAd = nativeAd
        
        return garageNativeAdView
    }
}

class GarageNativeAdView: NativeAdView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        let headlineLabel = UILabel()
        headlineLabel.font = .boldSystemFont(ofSize: 14)
        headlineLabel.textColor = .white
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(headlineLabel)
        self.headlineView = headlineLabel
        
        let bodyLabel = UILabel()
        bodyLabel.font = .systemFont(ofSize: 12)
        bodyLabel.textColor = .lightGray
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bodyLabel)
        self.bodyView = bodyLabel
        
        let callToActionButton = UIButton()
        callToActionButton.backgroundColor = .systemRed
        callToActionButton.titleLabel?.font = .boldSystemFont(ofSize: 12)
        callToActionButton.setTitleColor(.white, for: .normal)
        callToActionButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(callToActionButton)
        self.callToActionView = callToActionButton
        
        let iconImageView = UIImageView()
        iconImageView.backgroundColor = UIColor(white: 1, alpha: 0.1)
        iconImageView.layer.cornerRadius = 8
        iconImageView.clipsToBounds = true
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconImageView)
        self.iconView = iconImageView
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            headlineLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            headlineLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            headlineLabel.trailingAnchor.constraint(equalTo: callToActionButton.leadingAnchor, constant: -12),
            
            bodyLabel.leadingAnchor.constraint(equalTo: headlineLabel.leadingAnchor),
            bodyLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 2),
            bodyLabel.trailingAnchor.constraint(equalTo: headlineLabel.trailingAnchor),
            
            callToActionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            callToActionButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            callToActionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            callToActionButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
}

