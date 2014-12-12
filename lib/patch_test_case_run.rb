require 'test/unit/testcase'

module Test
  module Unit
    class TestCase
      unless method_defined?(:run_pre_contentful_patch)
        alias_method :run_pre_contentful_patch, :run
      end
      def run(result, &block)
        use_dummy_asset_id_so_local_file_mod_times_dont_affect_contentful_tests
        run_pre_contentful_patch(result, &block)
        try_auto_assert_contentful
      end

      protected
      def use_dummy_asset_id_so_local_file_mod_times_dont_affect_contentful_tests
        ENV['RAILS_ASSET_ID'] = 'DUMMY_ASSET_ID'
      end

      def try_auto_assert_contentful
        return unless defined?(@response) and @response.is_a?(ActionController::TestResponse)
        return unless defined?(CONTENTFUL_AUTO) and CONTENTFUL_AUTO
        assert_contentful unless defined?(@contentful_labels)
      end
    end
  end
end

begin # Push through the Rails 2.1 testcase wrapper without breaking older versions
  require 'active_support/test_case'
  module ActiveSupport
    class TestCase
      setup do
        ENV['RAILS_ASSET_ID'] = 'DUMMY_ASSET_ID'
      end
      teardown do
#        try_auto_assert_contentful
      end
    end
  end
rescue
end


