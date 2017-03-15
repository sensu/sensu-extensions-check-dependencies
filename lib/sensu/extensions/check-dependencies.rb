require "sensu/extension"
require "timeout"
require "net/http"

module Sensu
  module Extension
    class CheckDependencies < Filter
      def name
        "check_dependencies"
      end

      def description
        "filter events when an event exists for a check dependency"
      end

      # Make an HTTP GET request to the Sensu API, using the URI
      # path provided. Uses Sensu settings to determine how to
      # connect to the API.
      #
      # @param path [String]
      # @return [Object] http response object.
      def sensu_api_get_request(path)
        api = @settings[:api] || {}
        request = Net::HTTP::Get.new(path)
        if api[:user]
          request.basic_auth(api[:user], api[:password])
        end
        Net::HTTP.new(api[:host] || '127.0.0.1', api[:port] || 4567).start do |http|
          http.request(request)
        end
      end

      # Check to see if an event exists for a client/check pair. This
      # method is looking for a HTTP response code of `200`.
      #
      # @param client_name [String]
      # @param check_name [String]
      # @return [Boolean]
      def event_exists?(client_name, check_name)
        path = "/events/#{client_name}/#{check_name}"
        response = sensu_api_get_request(path)
        response.code.to_i == 200
      end

      # Determine if an event exists for any of the check
      # dependencies declared in the event data, specified in array,
      # check `dependencies`. A check dependency can be a check
      # executed by the same Sensu client (eg. `check_app`), or a
      # client/check pair (eg.`i-424242/check_mysql`).
      #
      # @param event [Hash]
      # @return [Boolean]
      def dependency_events_exist?(event)
        if event[:check][:dependencies].is_a?(Array)
          event[:check][:dependencies].any? do |dependency|
            begin
              check_name, client_name = dependency.split("/").reverse
              client_name ||= event[:client][:name]
              event_exists?(client_name, check_name)
            rescue => error
              @logger.error("failed to query api for a check dependency event", :error => error)
              false
            end
          end
        else
          false
        end
      end

      def run(event, &callback)
        filter = Proc.new do
          begin
            Timeout::timeout(10) do
              if dependency_events_exist?(event)
                ["event exists for check dependency", 0]
              else
                ["no current events for check dependencies", 1]
              end
            end
          rescue => error
            @logger.error("check dependencies filter error", :error => error.to_s)
            ["check dependencies filter error: #{error}", 1]
          end
        end
        EM.defer(filter, callback)
      end
    end
  end
end
