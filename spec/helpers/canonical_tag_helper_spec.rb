# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe CanonicalTagHelper, type: :helper do
  describe '#canonical_tag' do
    subject { helper.canonical_tag('spreestore.example.com') }

    before do
      controller.request.path = path
      controller.params.merge!(params)
    end

    let(:path) { '/' }
    let(:params) { { 'action' => 'index' } }

    it { is_expected.to eq('<link href="http://spreestore.example.com/" rel="canonical">') }

    context 'when the action is a member action' do
      let(:path) { '/products/some-bread' }
      let(:params) { { 'action' => 'show' } }

      it { is_expected.to eq('<link href="http://spreestore.example.com/products/some-bread" rel="canonical">') }
    end

    context 'when the path has a format extension' do
      let(:path) { '/products/some-bread.html' }
      let(:params) { { 'action' => 'show' } }

      it { is_expected.to eq('<link href="http://spreestore.example.com/products/some-bread" rel="canonical">') }
    end

    context 'when a collection action has query parameters' do
      let(:path) { '/products' }
      let(:params) { { 'action' => 'index', 'taxon' => '1', 'page' => '2' } }

      it 'keeps only the parameters that identify distinct content' do
        is_expected.to eq('<link href="http://spreestore.example.com/products/?page=2&amp;taxon=1" rel="canonical">')
      end
    end

    context 'when query parameters are not canonical' do
      let(:path) { '/products' }
      let(:params) { { 'action' => 'index', 'utm_source' => 'newsletter', 'sort' => 'price' } }

      it 'drops them' do
        is_expected.to eq('<link href="http://spreestore.example.com/products/" rel="canonical">')
      end
    end

    context 'when a canonical parameter is blank' do
      let(:path) { '/products' }
      let(:params) { { 'action' => 'index', 'keywords' => '' } }

      it 'drops it' do
        is_expected.to eq('<link href="http://spreestore.example.com/products/" rel="canonical">')
      end
    end

    context 'when the request is on a non-default port' do
      before { controller.request.env['HTTP_HOST'] = 'localhost:3000' }

      it { is_expected.to eq('<link href="http://spreestore.example.com:3000/" rel="canonical">') }
    end
  end
end
