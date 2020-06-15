require 'json'
package = JSON.parse(File.read('package.json'))

Pod::Spec.new do |s|

  s.name            = package["name"]
  s.version         = package["version"]
  s.homepage        = package["homepage"]
  s.summary         = package["description"]
  s.license         = package["license"]
  s.author          = package["author"]
  s.platform        = :ios, "9.0"
  s.source          = { :git => "https://github.com/codebite-tech/react-native-capture-callback", :tag => "v#{s.version}" }
  s.source_files    = 'ios/*.{h,m}'

  s.dependency 'React'

end
