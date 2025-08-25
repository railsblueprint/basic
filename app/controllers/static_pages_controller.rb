class StaticPagesController < ApplicationController
  def home
    @page = Page.active.find_by(url: "")
    return if @page.blank? # renders default home

    set_meta_from_page
    render :page
  end

  def page # rubocop:disable Metrics/AbcSize
    # First check database-driven pages (existing behavior)
    @page = Page.active.find_by(url: params[:path])

    if @page.present?
      set_meta_from_page
      render :page
    elsif view_template_exists?(params[:path])
      # Fall back to view file if it exists
      # Override params[:action] for proper CSS class (converts slashes to hyphens)
      self.params = params.merge(action: params[:path].to_s.tr("/", "-"))
      render template: "static_pages/#{params[:path]}"
    else
      render_404
    end
  end

  private

  def set_meta_from_page
    set_meta_tags title:       @page.title,
                  seo_title:   @page.seo_title,
                  description: @page.seo_description,
                  keywords:    @page.seo_keywords
  end

  # Check if a template exists for the given action
  def view_template_exists?(action_name)
    lookup_context.exists?(action_name, ["static_pages"])
  end
end
