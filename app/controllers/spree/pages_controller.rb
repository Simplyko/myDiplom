module Spree
    class PagesController < Spree::StoreController
    layout 'spree/layouts/spree_application'
        def index
            @avg_rating_products = Spree::Product.avgrating
        end
    end
end