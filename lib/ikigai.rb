#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

$LOAD_PATH.unshift __dir__

module Kernel
  alias λ lambda
end

module Ikigai 
  # autoload :Log,            'muletto/log'
  autoload :Config,         'ikigai/config'
  autoload :Mail,           'ikigai/mail'
  autoload :Initialization, 'ikigai/initialization'
  autoload :Application,    'ikigai/application'
  autoload :BaseController, 'ikigai/base_controller'
  autoload :BaseModel,      'ikigai/base_model'
end
