# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{kvc}
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Stephen Celis"]
  s.date = %q{2009-06-27}
  s.description = %q{KVC (Key-Value Configuration) provides a powerful, transparent way to maintain
mutable app settings in the database.}
  s.email = ["stephen@stephencelis.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "lib/kvc.rb", "lib/kvc/settings.rb", "lib/kvc/settings_proxy.rb", "tasks/kvc_tasks.rake", "test/kvc_test.rb", "uninstall.rb"]
  s.homepage = %q{http://github.com/stephencelis/kvc}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{kvc}
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{KVC (Key-Value Configuration) provides a powerful, transparent way to maintain mutable app settings in the database.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe>, [">= 2.0.0"])
    else
      s.add_dependency(%q<hoe>, [">= 2.0.0"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 2.0.0"])
  end
end
