require 'gitolite/config'

describe Gitolite::Config::Repo do
  before(:each) do
    @repo = Gitolite::Config::Repo.new("CoolRepo")
  end

  describe '#new' do
    it 'should create a repo called "CoolRepo"' do
      @repo.name.should == "CoolRepo"
    end
  end

  describe '#add_permission' do
    it 'should allow adding a permission to the permissions list' do
      @repo.add_permission("RW+")
      @repo.permissions.length.should == 1
      @repo.permissions.first.first.should == "RW+"
    end

    it 'should allow adding a permission while specifying a refex' do
      @repo.add_permission("RW+", "refs/heads/master")
      @repo.permissions.length.should == 1
      @repo.permissions.first.first.should == "RW+"
      @repo.permissions.first.last.first.first.should == "refs/heads/master"
    end

    it 'should allow specifying users individually' do
      @repo.add_permission("RW+", "", "bob", "joe", "susan", "sam", "bill")
      @repo.permissions["RW+"][""].should == %w[bob joe susan sam bill]
    end

    it 'should allow specifying users as an array' do
      users = %w[bob joe susan sam bill]

      @repo.add_permission("RW+", "", users)
      @repo.permissions["RW+"][""].should == users
    end

    it 'should not allow adding an invalid permission via an InvalidPermissionError' do
      expect {@repo.add_permission("BadPerm")}.to raise_error
    end
  end

  describe 'git config options' do
    it 'should allow setting a git configuration option' do
      email = "bob@zilla.com"
      @repo.set_git_config("email", email).should == email
    end

    it 'should allow deletion of an existing git configuration option' do
      email = "bob@zilla.com"
      @repo.set_git_config("email", email)
      @repo.unset_git_config("email").should == email
    end

  end

  describe 'permission management' do
    it 'should combine two entries for the same permission and refex' do
      users = %w[bob joe susan sam bill]
      more_users = %w[sally peyton andrew erin]

      @repo.add_permission("RW+", "", users)
      @repo.add_permission("RW+", "", more_users)
      @repo.permissions["RW+"][""].should == users.concat(more_users)
      @repo.permissions["RW+"][""].length.should == 9
    end

    it 'should not list the same users twice for the same permission level' do
      users = %w[bob joe susan sam bill]
      more_users = %w[bob peyton andrew erin]
      even_more_users = %w[bob jim wayne courtney]

      @repo.add_permission("RW+", "", users)
      @repo.add_permission("RW+", "", more_users)
      @repo.add_permission("RW+", "", even_more_users)
      @repo.permissions["RW+"][""].should == users.concat(more_users).concat(even_more_users).uniq!
      @repo.permissions["RW+"][""].length.should == 11
    end
  end
end