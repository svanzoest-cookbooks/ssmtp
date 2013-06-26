describe_recipe 'ssmtp:default' do
    it 'installs ssmtp' do
      package("ssmtp").must_be_installed
    end

    it 'should create ssmtp.conf' do
      file("/etc/ssmtp/ssmtp.conf").must_exist.with(:owner, "root").and(:group, "mail").and(:mode, 0640)
    end
end
