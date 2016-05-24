module ActiveAdmin
  module Filters
    # This form builder defines methods to build filter forms such
    # as the one found in the sidebar of the index page of a standard resource.
    class FormBuilder < ::ActiveAdmin::FormBuilder
      include ::ActiveAdmin::Filters::FormtasticAddons
      self.input_namespaces = [::Object, ::ActiveAdmin::Inputs::Filters, ::ActiveAdmin::Inputs, ::Formtastic::Inputs]

      # TODO: remove input class finders after formtastic 4 (where it will be default)
      self.input_class_finder = ::Formtastic::InputClassFinder

      def filter(method, options = {})
        if method.present? && options[:as] ||= default_input_type(method)
          template.concat input(method, options)
        end
      end

      protected

      # Returns the default filter type for a given attribute. If you want
      # to use a custom search method, you have to specify the type yourself.
      def default_input_type(method, options = {})
        if method =~ /_(eq|equals|cont|contains|start|starts_with|end|ends_with)\z/
          :string
        elsif klass._ransackers.key?(method.to_s)
          klass._ransackers[method.to_s].type
        elsif reflection_for(method) || polymorphic_foreign_type?(method)
          :select
        elsif column = column_for(method)
          case column.type
          when :date, :datetime
            :date_range
          when :string, :text
            :string
          when :integer, :float, :decimal
            :numeric
          when :boolean
            :boolean
          end
        end
      end
    end


    # This module is included into the view
    module ViewHelper

      # Helper method to render a filter form
      def active_admin_filters_form_for(search, filters, options = {})
        defaults = { builder: ActiveAdmin::Filters::FormBuilder,
                     url: collection_path,
                     html: {class: 'filter_form'} }
        required = { html: {method: :get},
                     as: :q }
        options  = defaults.deep_merge(options).deep_merge(required)

        buffer = ''
        ActiveAdminFilter.where(collection: params[:controller]).find_each do |filter|
          link = link_to(filter.name, collection_path(q: filter.params, saved_filter: filter.id))
          remove = link_to('x', '#', class: 'delete', data: { name: filter.name, url: "#{collection_path}/delete_filter" })
          opts = {}
          if params[:saved_filter] && filter.id == params[:saved_filter].to_i
            opts.update(class: 'current_filter')
          end
          buffer += content_tag(:li, link + ' ' + remove, opts)
        end
        unless buffer.empty?
          buffer = content_tag(:label, I18n.t('active_admin.sidebars.saved_filters'), class: 'label') +
                   content_tag(:ul, buffer.html_safe, class: 'saved_filters')
        end

        buffer += form_for search, options do |f|
          filters.each do |attribute, opts|
            next if opts.key?(:if)     && !call_method_or_proc_on(self, opts[:if])
            next if opts.key?(:unless) &&  call_method_or_proc_on(self, opts[:unless])

            f.filter attribute, opts.except(:if, :unless)
          end

          buttons = content_tag :div, class: "buttons" do
            f.submit(I18n.t('active_admin.filters.buttons.filter')) +
              link_to(I18n.t('active_admin.filters.buttons.save'), '#', class: 'save_filters_btn', data: { url: "#{collection_path}/create_filter" }) +
              link_to(I18n.t('active_admin.filters.buttons.clear'), '#', class: 'clear_filters_btn') +
              hidden_field_tags_for(params, except: except_hidden_fields)
          end

          f.template.concat buttons
        end

        buffer.html_safe
      end

      private

      def except_hidden_fields
        [:q, :page]
      end
    end

  end
end
