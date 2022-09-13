module TabsHelper
  class TabBuilder
    delegate :content_tag, :capture, :concat, :tag, to: :@template
    attr_accessor :tabs

    def initialize(template, options={})
      @template = template
      @tabs = []
      @options = options
    end

    def add(options={}, &)
      body = capture(&)
      @tabs << options.merge(body:)
    end

    def titles
      content_tag "nav" do
        content_tag "div", id: "tabs_#{object_id}", class: "nav nav-tabs #{@options[:nav_class]}", role: "tablist" do
          tabs.each.with_index do |tab, i|
            concat(content_tag("button",
                               id:               "#nav-#{object_id}-#{i}-tab",
                               class:            "nav-link #{'active' if i.zero?}",
                               "aria-controls":  "nav-#{object_id}-#{i}",
                               "aria-selected":  i.zero?,
                               "data-bs-target": "#nav-#{object_id}-#{i}",
                               "data-bs-toggle": "tab",
                               role:             "tab",
                               type:             "button") do
                     tab[:title]
                   end)
          end
        end
      end
    end

    def bodies
      content_tag "div", id: "#{object_id}-tabContent", class: "tab-content" do
        tabs.each.with_index do |tab, i|
          concat(content_tag("div", id: "nav-#{object_id}-#{i}", class: "tab-pane fade #{'show active' if i.zero?}",
"aria-labelledby": "nav-#{object_id}-#{i}-tab", role: "tabpanel") do
                   tab[:body]
                 end)
        end
      end
    end
  end

  def tabs(options={})
    builder = TabBuilder.new self, options
    yield builder
    builder.titles + builder.bodies
  end
end
