# This file is subject to the terms and conditions defined in
# file 'LICENSE.txt', which is part of this source code package.

class Counter
  attr_accessor :success, :failure

  def initialize(options = {})
    @success = options[:success].to_i || 0
    @failure = options[:fail].to_i || 0
  end

  def success!
    @success = @success.next
  end

  def failure!
    @failure = @failure.next
  end
end
