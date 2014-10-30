#chef_api :config
site :opscode

metadata

group :test do
  cookbook "apt", '~> 2.6'
  cookbook "yum", '~> 2.4'
  cookbook "minitest-handler"

  # https://github.com/opscode/test-kitchen/issues/28
  require 'pathname'
  cb_dir = ::File.join('.', 'test', 'kitchen', 'cookbooks')
  if ::File.exist?(cb_dir)
    Pathname.new(cb_dir).children.select(&:directory?).each do |c|
      cookbook c.basename.to_s, :path => ::File.join(cb_dir, c.basename.to_s).to_s
    end
  end
end
