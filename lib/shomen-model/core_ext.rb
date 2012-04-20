class Hash
  def to_h
    self
  end unless method_defined?(:to_h)
end
