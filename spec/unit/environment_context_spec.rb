# vim: set ts=2 sw=2 ai et ruler:
require 'spec_helper'
describe 'JumanjimanSpecHelper::EnvironmentContext' do
  # create two keys, each with random name
  key1 = (0...8).map{(65+rand(26)).chr}.join # exist before examples
  key2 = (0...8).map{(65+rand(26)).chr}.join # create within examples

  # both keys get this value
  value = 'boogabooga'

  before :all do
    ENV[key1] = value
    @reporter = RSpec::Core::Reporter.new
  end

  after :all do
    # remove persistent key
    ENV.delete(key1)
  end

  it 'is accessible as JumanjimanSpecHelper::EnvironmentContext' do
    JumanjimanSpecHelper::EnvironmentContext
  end

  context 'when included' do
    it 'preserves pre-existing env var' do
      group = RSpec::Core::ExampleGroup.describe do
        include JumanjimanSpecHelper::EnvironmentContext
      end
      group.run(@reporter)
      ENV[key1].should == value
    end

    it 'restores pre-existing env var if changed within example' do
      group = RSpec::Core::ExampleGroup.describe do
        include JumanjimanSpecHelper::EnvironmentContext
        it {ENV[key1] = value.reverse} # change env var in example
      end
      group.run(@reporter)
      ENV[key1].should == value
    end

    it 'discards env var if created within example' do
      group = RSpec::Core::ExampleGroup.describe do
        include JumanjimanSpecHelper::EnvironmentContext
        it {ENV[key2] = value} # create env var in example
      end
      group.run(@reporter)
      ENV[key2].should be_nil
    end
  end

  context 'when not included (i.e., default rspec behavior)' do
    it 'preserves pre-existing env var' do
      group = RSpec::Core::ExampleGroup.describe do
      end
      group.run(@reporter)
      ENV[key1].should == value
    end

    it 'clobbers env var if changed within example' do
      group = RSpec::Core::ExampleGroup.describe do
        it {ENV[key1] = value.reverse} # change env var in example
      end
      group.run(@reporter)
      ENV[key1].should == value.reverse
    end

    it 'persists env var if created within example' do
      group = RSpec::Core::ExampleGroup.describe do
        it {ENV[key2] = value} # create env var in example
      end
      group.run(@reporter)
      ENV[key2].should == value
    end
  end
end
