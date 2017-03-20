module Fastlane
  module Actions
    class AwsDeviceFarmPackageAction < Action
      def self.run(params)
        FileUtils.rm_rf "#{File.expand_path(params[:derrived_data_path])}/packages"

        Dir["#{File.expand_path(params[:derrived_data_path])}/Build/Products/#{params[:configuration]}-iphoneos/*.app"].each do |app|
          if app.include? 'Runner'

            if params[:calabash] && params[:calabash] == true
              FileUtils.mkdir_p "#{File.expand_path(params[:derrived_data_path])}/packages/runner/Payload"
              FileUtils.cp_r app, "#{File.expand_path(params[:derrived_data_path])}/packages/runner/Payload"
              Actions.sh "cd #{File.expand_path(params[:derrived_data_path])}/packages/runner/; zip --recurse-paths -D --quiet #{File.expand_path(params[:derrived_data_path])}/packages/runner.ipa .;"

              ENV['FL_AWS_DEVICE_FARM_TEST_PATH'] = "#{File.expand_path(params[:derrived_data_path])}/packages/runner.ipa"
            end

          else

            FileUtils.mkdir_p "#{File.expand_path(params[:derrived_data_path])}/packages/app/Payload"
            FileUtils.cp_r app, "#{File.expand_path(params[:derrived_data_path])}/packages/app/Payload"
            Actions.sh "cd  #{File.expand_path(params[:derrived_data_path])}/packages/app/; zip --recurse-paths -D --quiet #{File.expand_path(params[:derrived_data_path])}/packages/app.ipa .;"

            ENV['FL_AWS_DEVICE_FARM_PATH'] = "#{File.expand_path(params[:derrived_data_path])}/packages/app.ipa"

          end
        end

        # Calabash feature zipping
        if params[:calabash] && params[:calabash] == true
          Actions.sh "zip -r -X --quiet #{File.expand_path(params[:derrived_data_path])}/packages/features.zip features;"
          ENV['FL_AWS_DEVICE_FARM_CALABASH_TEST_PACKAGE_PATH'] = "#{File.expand_path(params[:derrived_data_path])}/packages/features.zip"
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Packages .app from deriveddata to an aws-compatible ipa'
      end

      def self.details
        'Packages .app to .ipa'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key:         :derrived_data_path,
            env_name:    'FL_AWS_DEVICE_FARM_DERIVED_DATA',
            description: 'Derrived Data Path',
            is_string:   true,
            optional:    false
          ),
          FastlaneCore::ConfigItem.new(
            key:         :configuration,
            env_name:    'FL_AWS_DEVICE_FARM_CONFIGURATION',
            description: 'Configuration',
            is_string:   true,
            optional:    true,
            default_value: "Development"
          ),
          FastlaneCore::ConfigItem.new(
            key:           :calabash,
            env_name:      'FL_AWS_DEVICE_FARM_CALABASH_ENABLED',
            description:   'Calabash tests enabled',
            is_string:     false,
            optional:      true,
            default_value: false
          )
        ]
      end

      def self.output
        []
      end

      def self.return_value
      end

      def self.authors
        ["hjanuschka"]
      end

      def self.is_supported?(platform)
        platform == :ios || platform == :android
      end
    end
  end
end
