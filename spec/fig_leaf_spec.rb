require "rspec"
require_relative '../lib/fig_leaf'

RSpec.describe FigLeaf do
  before do
    wipe_classes
    expect { Child.hide(Parent) }.to raise_error NoMethodError
    expect(Child.child_public_class_method).to eq(42)
    expect(Child.new.child_public_instance_method).to eq(42)
    expect(Child.new.grandparent_public_instance_method).to eq(42)
    expect(Child.new.parent_public_instance_method).to eq(42)
    expect(Child.new.second_child_public_instance_method).to eq(42)
  end

  it 'hides a single class method' do
    class Child
      include FigLeaf
      hide_singletons :child_public_class_method
    end

    expect do
      Child.child_public_class_method
    end.to raise_error NoMethodError
  end

  it 'hides instance methods' do
    class Child
      include FigLeaf
      hide :child_public_instance_method
    end

    expect { Child.new.child_public_instance_method }.to raise_error NoMethodError
  end

  it 'deeply hides methods from ancestor objects' do
    class Child
      include FigLeaf
      hide Parent, ancestors: true
    end

    expect { Child.new.grandparent_public_instance_method }.to raise_error NoMethodError
    expect { Child.new.parent_public_instance_method }.to raise_error NoMethodError
  end

  it 'does not hide ancestors if not asked to' do
    class Child
      include FigLeaf
      hide Parent
    end

    expect(Child.new.grandparent_public_instance_method).to eq(42)
  end

  def wipe_classes
    if defined? Grandparent
      Object.send(:remove_const, :Grandparent)
      Object.send(:remove_const, :Parent)
      Object.send(:remove_const, :Child)
    end
    load File.join(File.dirname(__FILE__), 'classes_for_tests.rb')
  end

  it 'allows you to specify single instance method to keep visible' do
    class Child
      include FigLeaf
      hide self, except: :second_child_public_instance_method
    end

    expect { Child.new.child_public_instance_method }.to raise_error NoMethodError
    expect(Child.new.second_child_public_instance_method).to eq(42)
  end

  it 'allows you to specify entire class instance method exceptions to keep visible' do
    class Child
      include FigLeaf
      hide Parent, ancestors: true, except: [Grandparent]
    end

    expect(Child.new.grandparent_public_instance_method).to eq(42)
    expect { Child.new.parent_public_instance_method }.to raise_error NoMethodError
  end

  it 'allows you to specify entire class instance method exceptions to keep visible' do
    class Child
      include FigLeaf
      hide Parent, ancestors: true, except: [Grandparent]
    end

    expect(Child.new.grandparent_public_instance_method).to eq(42)
    expect { Child.new.parent_public_instance_method }.to raise_error NoMethodError
  end

  it 'allows you to specify more than one exception to keep visible' do
    class Child
      include FigLeaf
      hide self, except: [:second_child_public_instance_method, :grandparent_public_instance_method]
    end

    expect { Child.new.child_public_instance_method }.to raise_error NoMethodError
    expect(Child.new.second_child_public_instance_method).to eq(42)
    expect(Child.new.grandparent_public_instance_method).to eq(42)
  end

  it 'does not pollute your interface by making its own methods public' do
    class Child
      include FigLeaf
      hide self
    end

    expect { Child.hide(Parent) }.to raise_error NoMethodError
  end
end
