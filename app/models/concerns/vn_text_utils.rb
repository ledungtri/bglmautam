module VnTextUtils
  extend ActiveSupport::Concern

  NORMALIZE_RULES = [
    { regex: /[áàảãạăắặằẳẵâấầẩẫậ]/, replacement: 'a' },
    { regex: /[ÁÀẢÃẠĂẮẶẰẲẴÂẤẦẨẪẬ]/, replacement: 'A' },
    { regex: /[íìỉĩị]/, replacement: 'i' },
    { regex: /[ÍÌỈĨỊ]/, replacement: 'I' },
    { regex: /[úùủũụưứừửữự]/, replacement: 'u' },
    { regex: /[ÚÙỦŨỤƯỨỪỬỮỰ]/, replacement: 'U' },
    { regex: /[éèẻẽẹêếềểễệ]/, replacement: 'e' },
    { regex: /[ÉÈẺẼẸÊẾỀỂỄỆ]/, replacement: 'E' },
    { regex: /[óòỏõọôốồổỗộơớờởỡợ]/, replacement: 'o' },
    { regex: /[ÓÒỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢ]/, replacement: 'O' },
    { regex: /đ/, replacement: 'd' },
    { regex: /Đ/, replacement: 'D' },
    { regex: /[ýỳỷỹỵ]/, replacement: 'y' },
    { regex: /[ÝỲỶỸỴ]/, replacement: 'Y' }
  ].freeze

  def normalize(string)
    NORMALIZE_RULES.each { |rule| string = string&.gsub(rule[:regex], rule[:replacement]) }
    string
  end

  def reverse(string)
    string.split(/\s+/).reverse!.join(' ')
  end
end