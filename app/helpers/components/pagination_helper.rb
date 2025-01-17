module Components
  module PaginationHelper
    def paginated_page_param(pagy, page)
      @page_param ||= pagy.vars[:page_param] || Pagy::VARS[:page_param]
      @query_parameters ||= request.query_parameters

      @query_parameters.merge(@page_param => page)
    end

    def paginated_path(path_helper, pagy, page, param)
      page_query = paginated_page_param(pagy, page)
      send(path_helper, param, page_query)
    end
  end
end
