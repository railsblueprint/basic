module TurboMethods
  extend ActiveSupport::Concern

  included do
    def turbo_frame_breakout?
      flash[:turbo_breakout].present?.tap { flash.delete(:turbo_breakout) }
    end

    helper_method :turbo_frame_request?

    layout lambda {
      !turbo_frame_breakout? && turbo_frame_request? ? "turbo_rails/frame" : layout_name
    }
    add_flash_types :turbo_breakout
  end

  class_methods do
    def use_layout layout_name
      define_method :layout_name do
        layout_name
      end
    end
  end
end
