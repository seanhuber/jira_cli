module JiraCli
  class OutputError < StandardError
    attr_reader :actual_output

    def initialize msg, actual_output
      @actual_output = actual_output
      super msg
    end
  end
end
