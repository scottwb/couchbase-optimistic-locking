notification :emacs
notification :terminal

group :all do
  guard :rspec, :all_on_start => true do
    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^lib/(.+)\.rb$})          { |m| "spec/lib/#{m[1]}_spec.rb" }
    watch('spec/spec_helper.rb')       { "spec" }
  end
end

group :focus do
  guard :rspec, :cli => '--tag focus', :all_on_start => true do
    watch(%r{^spec/lib/.+_spec\.rb$})
    watch(%r{^lib/(.+)\.rb$})          { |m| "spec/lib/#{m[1]}_spec.rb" }
    watch('spec/spec_helper.rb')       { "spec" }
  end
end
