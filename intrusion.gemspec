# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{intrusion}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Simon Wepfer"]
  s.cert_chain = ["/home/sw/gem-public_cert.pem"]
  s.date = %q{2010-12-30}
  s.description = %q{intrusion detection and prevention for rails apps}
  s.email = %q{sw@netsense.ch}
  s.extra_rdoc_files = ["README.rdoc", "lib/intrusion.rb"]
  s.files = ["Manifest", "README.rdoc", "Rakefile", "lib/intrusion.rb", "intrusion.gemspec"]
  s.homepage = %q{http://github.com/symontech/intrusion}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Intrusion", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{intrusion}
  s.rubygems_version = %q{1.3.7}
  s.signing_key = %q{/home/sw/gem-private_key.pem}
  s.summary = %q{intrusion detection and prevention for rails apps}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
