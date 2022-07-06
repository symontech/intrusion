# Intrusion

Intrusion is a gem helping you to block objects for IP adresses within your Rails Application.

## Installation
Add it to your `Gemfile`:
```
gem 'intrusion'
```
then run
```
# bundle install
```

## Setup

### Prepare Database
If you want to store the ids status on object level,
create an `ids` text attribute for the ApplicationRecord you want to protect and migrate, e.g:
```
# rails generate migration add_ids_to_accounts ids:text
# rails db:migrate
```
#### Include in the model:
```
class Account < ApplicationRecord
    include Intrusion
end
```

## Configuration
Intrusion takes a configure block that allows you to set a threshold for hard block (defaults to 10):
```
class Account < ApplicationRecord
  include Intrusion
  Intrusion.configure do |config|
    config.threshold = 5
  end
end
```

## Implementing in the Application Controller
It might be a good idea to raise a `SecurityError` whenever something's happening that looks like an attack.

Then catch and re-raise in the `application_controller.rb`, for example:
```
class ApplicationController < ActionController::Base
  
  before_action :allowed_by_ids
  
  rescue_from SecurityError, with: :hit_ids
  
  protected

  def hit_ids(exception)
    @account.ids_report!(request.remote_ip)
    raise exception
  end

  def allowed_by_ids
    head :unauthorized if @account.ids_is_blocked?(request.remote_ip)
  end

end
```

## Examples:

### Check if IP address is blocked
```
> return 'your ip is blocked' if @account.ids_is_blocked?(request.remote_addr)
```

### Report suspicious activity
The internal counter will be increased. If you do this 10 times, the ip is considered blocked
```
> @account.ids_report!(request.remote_addr)
```
### Immediate block
```
> @account.ids_report!(request.remote_addr, true)
```
### Reset counter
```
> @account.ids_unblock!(request.remote_addr)
```

### Blocking objects with keywords
You are not limited to IP addresses. You may use any keyword, for instance:
```
> @account.ids_report!('self')
```
## Run tests
```
# ruby -Itest test/intrusion_test.rb
```

## Copyright

(c) 2010 - 2022 Simon Duncombe