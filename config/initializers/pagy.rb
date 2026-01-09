
require 'pagy/extras/metadata'
require 'pagy/extras/overflow'
require 'pagy/extras/limit'
Pagy::DEFAULT[:limit] = 10
Pagy::DEFAULT[:overflow] = :last_page