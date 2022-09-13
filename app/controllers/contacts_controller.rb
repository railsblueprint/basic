class ContactsController < ApplicationController
  def new
    @command ||= ContactUsCommand.new(name: current_user&.full_name, email: current_user&.email)

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("frame_new_contact_us_command", partial: "form") }
      format.html         { render "new" }
    end
  end

  # rubocop:disable Metrics/AbcSize
  # TODO: how i can fix it?
  def create
    ContactUsCommand.call_for(params) do |command|
      @command = command
      command.on :ok do
        respond_to do |format|
          format.turbo_stream {
            render turbo_stream: turbo_stream.replace("frame_new_contact_us_command", partial: "success")
          }
          format.html         { redirect_to action: :new }
        end
      end
      command.on :invalid, :abort do
        respond_to do |format|
          format.turbo_stream {
            render turbo_stream: turbo_stream.replace("frame_new_contact_us_command", partial: "form")
          }
          format.html { render "new" }
        end
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
end
