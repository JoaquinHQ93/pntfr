#
# VirtualSession implementation for iOS
#
require 'apns'
module Pntfr
  module VirtualSession
    class Ios < Pntfr::VirtualSession::Base
      def msg content, custom=nil
        configure_apns
        reset_msg
        @alert= content[:title]
        @alert+= "\n#{content[:description]}" if content.key?(:description)
        @sound= content[:sound]
        badge= content[:badge]
        @badge= content[:badge].to_i if badge
        add_custom_content(custom) if custom
        self
      end

      def notify
        n= {:alert => @alert, :sound => 'default'}
        if @badge
          n[:badge]= @badge
        elsif @session.methods.include?(:num_notifs)
          @session.num_notifs+= 1
          n[:badge]= @session.num_notifs
        end
        n[:sound]= @sound if @sound
        n.merge!(@custom) if @custom

        if Pntfr.test_env?
          Pntfr.add_delivery(@push_id, n)
        else
          ::APNS.send_notification(@push_id, n)
        end
        SuccessResponse.new
      end

      #-------------------------------------------------
      private
      #-------------------------------------------------

      def configure_apns
        config= Pntfr.config.apns
        APNS.host = config[:host]
        APNS.pem  = config[:pem]
        APNS.port = config[:port]
        APNS.pass = config[:pass]
      end
      def reset_msg
        @alert= @sound= @badge= nil
      end
      def add_custom_content custom
        @custom= {}
        custom.each_pair { |k, v|
          key= "acme-#{k}".to_sym
          @custom[key]= v
        }
      end
    end
  end
end