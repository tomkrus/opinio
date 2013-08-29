class Opinio::CommentsController < ApplicationController
  include Opinio::Controllers::InternalHelpers
  include Opinio::Controllers::Replies if Opinio.accept_replies

  def index
    @comments = resource.comments.page(params[:page])
  end

  def create
    @comment = resource.comments.build(comment_params)
    @comment.owner = send(Opinio.current_user_method)
    if @comment.save
      flash_area = :notice
      message = t('opinio.messages.comment_sent')
    else
      flash_area = :error
      message = t('opinio.messages.comment_sending_error')
    end

    respond_to do |format|
      format.js
      format.html do
        set_flash(flash_area, message)
        redirect_to(opinio_after_create_path(resource))
      end
    end
  end

  def destroy
    @comment = Opinio.model_name.constantize.find(params[:id])
    @comment.destroy
  end
  
  private

  def comment_params
    params.require(:comment).permit(:body, :owner_id, :commentable_id, :commentable_type)
  end 
  
end
