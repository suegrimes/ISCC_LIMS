class TaggedBuilder < ActionView::Helpers::FormBuilder
  HELPERS = field_helpers +
            %w(date_select calendar_date_select collection_select select) - 
            %w(hidden_field label fields_for)
  
  def self.created_tagged_field(method_name)
    define_method(method_name) do |field, *args|
      options = args.last.is_a?(Hash) ? args.pop : {}
      if options[:wraptags] == 'none'
        super(name, *args)
      else
        @template.content_tag(:th, label(field, options[:label]) +  @template.content_tag(:td, super(name, *args), :colspan => options[:tdcolspan]))
      end
    end
  end
  
  HELPERS.each do |fld_helper|
    created_tagged_field(fld_helper)
  end
  
end