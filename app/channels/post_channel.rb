class PostChannel < ApplicationCable::Channel
  def subscribed
    stream_for Post.find(params[:id])
  end
end
