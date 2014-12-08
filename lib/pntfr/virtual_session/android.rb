#
# VirtualSession implementation for Android
#

module Pntfr
  module VirtualSession
    class Android < Pntfr::VirtualSession::Base
      def initialize session
        super
        @notification_key= Pntfr.config.gcm[:notification_key]
      end

      def msg content
        @data= {
          :title        => content[:title],
          :description  => content[:description],
        }
        self
      end
      def notify
        options = {data: @data}
        if Pntfr.test_env?
          Pntfr.add_delivery(@push_id, options)
        else
          gcm= GCM.new(@notification_key)
          gcm.send_notification(@push_id, options)
        end
      end

    end
  end
end
