require 'omniauth-oauth2'
require 'base64'

module OmniAuth
  module Strategies
    class ClassLink < OmniAuth::Strategies::OAuth2
      option :name, :classlink
      option :client_options, {
        site:          'https://launchpad.classlink.com',
        authorize_url: '/oauth2/v2/auth',
        token_url:     '/oauth2/v2/token'
      }
      option :fields, [:email, :profile]
      
      uid{ "#{raw_info['SourcedId']}_#{raw_info['TenantId']}" }

      def authorize_params
        super.tap do |params|
          params[:scope] = [:email, :profile]
          params[:response_type] = :code
        end
      end

      info do
        {
          name: raw_info['DisplayName'],
          email: raw_info['Email'],
          role: raw_info['Role']
        }
      end

      extra do
        { 'raw_info' => raw_info }
      end

      def raw_info
        @raw_info ||= access_token.get('https://nodeapi.classlink.com/v2/my/info').parsed
      end
    end
  end
end
