class AttachedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if !options[:required] && !value.attached?

    if options[:required] && !value.attached?
      record.errors.add(attribute, :attached, message: options[:message] || "must be attached")
      return
    end

    if value.attached? && options[:content_type]
      unless value.content_type.in?(Array(options[:content_type]))
        record.errors.add(attribute, :content_type, message: "must be a JPEG image")
      end
    end
  end
end
