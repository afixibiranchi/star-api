module API
  module V1
    class API::V1::ResourcesController < ApplicationController
      before_action :set_resource_class, except: :search
      before_action :set_resource, only: [:show]
      respond_to :json

      def index
        @items = @resource_class.all
        if request.query_string.present?
          filters.each do |filter|
            @items = @items.where(filter)
          end
        end

        paginate json: @items, per_page: 500
      end

      def show
        render :json => @item
      end

      def search
        query = params[:q]
        models = [Star, ExoPlanet, LocalGroup, OpenCluster, Constellation]
        search_response = Hash[models.map {|m| [m.table_name, m.search(query)]}]
        render :json => search_response
      end

      private
      def resource
        params[:resource]
      end

      def filters
        max_filters.map {|key, value| "#{key} < #{value}"} +
        min_filters.map {|key, value| "#{key} > #{value}"}
      end

      def max_filters
        params[:max] = [] if params[:max].blank?
        params[:max].select {|key, value| @resource_class.column_names.include? key.to_s }
      end

      def min_filters
        params[:min] = [] if params[:min].blank?
        params[:min].select {|key, value| @resource_class.column_names.include? key.to_s }
      end

      def set_resource
        @item = @resource_class.find_by_label(params[:id])
      end

      def set_resource_class
        @resource_class = resource.classify.constantize
      end
    end
  end
end
