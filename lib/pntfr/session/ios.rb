#
# Session implementation for iOS
#
require 'apns'
module Pntfr
  module Session
    class Ios < Pntfr::Session::Base

      attr_reader :apns

      def initialize apns_config=nil
        configure_apns(apns_config)
      end

      def notify devices, notification
        apns_notifications= []
        devices.each do |device|
          if device_controls_badge(device)
            if !notification[:badge].nil?
              device.num_notifs= notification[:badge]
            else
              device.num_notifs+= 1
              notification[:badge]= device.num_notifs
            end
          end
          if Pntfr.test_env?
            Pntfr.add_delivery(device.push_id, notification)
          else
            apns_notif= APNS::Notification.new(device.push_id, notification)
            apns_notifications << apns_notif
          end
        end
        ::APNS.send_notifications(apns_notifications) if apns_notifications.any?
        SuccessResponse.new
      end

      #-------------------------------------------------
      private
      #-------------------------------------------------

      def device_controls_badge(device)
        device.methods.include?(:num_notifs)
      end

      def configure_apns config_override
        config= Pntfr.config.apns
        unless config_override.nil?
          config= config.clone.merge(config_override)
        end
        APNS.host = config[:host]
        APNS.pem  = config[:pem]
        APNS.port = config[:port]
        APNS.pass = config[:pass]
        @apns= APNS
      end
    end
  end
end