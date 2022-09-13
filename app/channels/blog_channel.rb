class BlogChannel < ApplicationCable::Channel
  def subscribed
    stream_for "blog"
  end
end
