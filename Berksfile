source 'https://supermarket.getchef.com'

metadata

group :integration do
  cookbook 'apt', '~> 2.6'
  cookbook "minitest-handler", "~> 1.3.2"

  # https://github.com/opscode/test-kitchen/issues/28
  require 'pathname'
  cb_dir = ::File.join('.', 'test', 'kitchen', 'cookbooks')
  if ::File.exist?(cb_dir)
    Pathname.new(cb_dir).children.select(&:directory?).each do |c|
      cookbook c.basename.to_s, :path => ::File.join(cb_dir, c.basename.to_s).to_s
    end
  end
end
