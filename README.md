# Intrusion

Intrusion is a gem helping you to block objects for IP adresses within your Rails Application.

## Installation
As usual:
```
# gem install intrusion
```
or add it to your `Gemfile`:
```
gem 'intrusion', '>= 0.2.0'
```
then run
```
# bundle install
```

## Setup

### Option A: Database
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
### Option B: File Store
If you have only one global object to protect and no ApplicationRecord you want to use, you can store the status in a file. You could create a helper class like this:
```
class MyGlobalIDS
  include Intrusion
  Intrusion.configure do |config|
    config.file = './tmp/my-intrusion-file.yml'
    config.threshold = 6
  end
end
```
Then you can block globally like this:
```
MyGlobalIDS.new.ids_report!(request.remote_addr, true)
```

Hint: Make sure your intrusion file is not deleted or moved during deployment.

## Configuration
Intrusion takes a configure block that allows you to set a threshold for hard block (defaults to 10) and a file store. See the example above.

## Implementing in the Application Controller
It might be a good idea to raise a `SecurityError` whenever something's happening that looks like an attack.

Then catch and re-raise in the `application_controller.rb`, for example:
```
class ApplicationController < ActionController::Base
  
  before_action :allowed_by_ids
  
  rescue_from SecurityError, with: :hit_ids
  
  protected

  def hit_ids(exception)
    MyGlobalIDS.new.ids_report!(request.remote_ip)
    raise exception
  end

  def allowed_by_ids
    head :unauthorized if MyGlobalIDS.new.ids_is_blocked?(request.remote_ip)
  end


  [...]
end
```

## Examples:

### Check if IP address is blocked
```
> return 'your ip is blocked' if Account.find(1).ids_is_blocked?(request.remote_addr)
```

### Report suspicious activity
The internal counter will be increased. If you do this 10 times, the ip is considered blocked
```
> Account.find(1).ids_report!(request.remote_addr)
```
### Immediate block
```
> Account.find(1).ids_report!(request.remote_addr, true)
```
### Reset counter
```
> Account.find(1).ids_unblock!(request.remote_addr)
```

### Blocking objects with keywords
You are not limited to IP addresses. You may use any keyword, for instance:
```
> Account.find(1).ids_report!('self')
```
## Run tests
```
# ruby -Itest test/intrusion_test.rb
```

## Copyright

(c) 2010 - 2022 Simon Duncombe