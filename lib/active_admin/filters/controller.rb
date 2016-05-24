module ActiveAdmin
  module Filters
    module Controller
      def create_filter
        params[:q].delete_if { |_, v| v.blank? }
        filter = ActiveAdminFilter.new collection: params[:controller], name: params[:name], params: params[:q]
        if filter.save
          render json: { url: collection_path(q: params[:q], saved_filter: filter.id) }, status: :created
        else
          render nothing: true, status: :bad_request
        end
      end

      def delete_filter
        filter = ActiveAdminFilter.find_by collection: params[:controller], name: params[:name]
        if filter
          filter.destroy!
          render nothing: true, status: :no_content
        else
          render nothing: true, status: :not_found
        end
      end
    end
  end
end
