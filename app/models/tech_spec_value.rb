class TechSpecValue < ActiveRecord::Base
  belongs_to :product

  def formatted_value(tech_spec, short = false)
    return text_value if text_value.present?

    if short 
      format_english_value(tech_spec)
    else
      "#{format_english_value(tech_spec)} (#{format_metric_value(tech_spec)})"
    end
  end
  
  def format_english_value(tech_spec)
    "#{format(english_value)} #{tech_spec.english_unit}"
  end
 
  def format_metric_value(tech_spec)
    "#{format(metric_value)} #{tech_spec.metric_unit}"
  end

  def tech_spec
    @tech_spec ||= TechSpec.find_by_cat_id(self.cat_id)
  end


  private


  def format(value)
    if value.to_i == value
      value.to_i.to_s
    else
      value.to_s
    end
  end
end
