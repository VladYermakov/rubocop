# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Util do
  before { stub_const('TestUtil', Class.new { include RuboCop::Cop::Util }) }

  describe '#line_range' do
    let(:source) do
      <<-RUBY
        foo = 1
        bar = 2
        class Test
          def some_method
            do_something
          end
        end
        baz = 8
      RUBY
    end

    let(:processed_source) { parse_source(source) }
    let(:ast) { processed_source.ast }

    let(:node) { ast.each_node.find(&:class_type?) }

    it 'returns line range of the expression' do
      line_range = described_class.line_range(node)
      expect(line_range).to eq(3..7)
    end
  end

  describe '#to_supported_styles' do
    subject { described_class.to_supported_styles(enforced_style) }

    context 'when EnforcedStyle' do
      let(:enforced_style) { 'EnforcedStyle' }

      it { is_expected.to eq('SupportedStyles') }
    end

    context 'when EnforcedStyleInsidePipes' do
      let(:enforced_style) { 'EnforcedStyleInsidePipes' }

      it { is_expected.to eq('SupportedStylesInsidePipes') }
    end
  end

  describe '#same_line?' do
    let(:source) do
      <<-RUBY
        @foo + @bar
        @baz
      RUBY
    end

    let(:processed_source) { parse_source(source) }
    let(:ast) { processed_source.ast }
    let(:nodes) { ast.each_descendant(:ivar).to_a }
    let(:node1) { nodes[0] }
    let(:node2) { nodes[1] }
    let(:node3) { nodes[2] }

    it 'returns true when two nodes are on the same line' do
      expect(described_class.same_line?(node1, node2)).to eq(true)
    end

    it 'returns false when two nodes are not on the same line' do
      expect(described_class.same_line?(node1, node3)).to be_falsey
    end

    it 'can use ranges' do
      expect(described_class.same_line?(node1.loc.expression, node2)).to eq(true)
    end

    it 'returns false if an argument is not a node or range' do
      expect(described_class.same_line?(node1, 5)).to be_falsey
      expect(described_class.same_line?(5, node2)).to be_falsey
    end
  end
end
