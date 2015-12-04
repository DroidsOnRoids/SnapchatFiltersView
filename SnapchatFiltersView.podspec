Pod::Spec.new do |s|
  s.name             = "SnapchatFiltersView"
  s.version          = "0.1.0"
  s.summary          = "Snapchat - like swipeable filters for views, photos, videos and live camera preview. Swift."

  s.description      = <<-DESC
                       Add Snapchat - like swipeable filters to your (camera) app!
                       Supports live camera preview, videos, images as well as UIViews.
                       You can overlay not only with filters but also with views or images - like the Snapchat's happy full battery or custom city / event overlays.
                       The cool thing is that you can filter any view! Not only images.

                       Written in Swift and maintained to work with newest releases.
                       Use Metal, Open-GL or Core Graphics under the hood.
                       DESC

  s.homepage         = "https://github.com/DroidsOnRoids/SnapchatFiltersView"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Andrzej Filipowicz" => "afilipowicz.4@gmail.com" }
  s.source           = { :git => "https://github.com/DroidsOnRoids/SnapchatFiltersView.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/NJFilipowicz'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'SnapchatFiltersView' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
