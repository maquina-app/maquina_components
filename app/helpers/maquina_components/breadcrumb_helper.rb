module MaquinaComponents
  module BreadcrumbHelper
    def breadcrumb(links = {}, current_page = nil)
      render "components/breadcrumb" do
        render "components/breadcrumb/list" do
          items = []

          # Add all links
          links.each_with_index do |(text, path), index|
            items << capture do
              render "components/breadcrumb/item" do
                render "components/breadcrumb/link", href: path do
                  text
                end
              end
            end

            # Add separator after each link except the last one (if there's no current page)
            if index < links.size - 1 || current_page.present?
              items << capture do
                render "components/breadcrumb/separator"
              end
            end
          end

          # Add current page if provided
          if current_page.present?
            items << capture do
              render "components/breadcrumb/item" do
                render "components/breadcrumb/page" do
                  current_page
                end
              end
            end
          end

          safe_join(items)
        end
      end
    end
  end
end
